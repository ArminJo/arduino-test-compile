#!/bin/bash

# entrypoint.sh
# Bash script to test compile all examples of an Arduino library repository for one board.
#
# Copyright (C) 2020  Armin Joachimsmeyer
# https://github.com/ArminJo/Github-Actions
# License: MIT
#

# Input parameter
readonly CLI_VERSION="$1"
readonly ARDUINO_BOARD_FQBN="$2"
readonly PLATFORM_URL="$3"
readonly LIBRARIES="$4"
readonly EXAMPLES_EXCLUDE="$5"
EXAMPLES_BUILD_PROPERTIES="$6"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'

#
# Echo input parameter
#
echo -e "\n\n"$YELLOW"Echo input parameter"
echo CLI_VERSION=$CLI_VERSION
echo ARDUINO_BOARD_FQBN=$ARDUINO_BOARD_FQBN
echo PLATFORM_URL=$PLATFORM_URL
echo LIBRARIES=$LIBRARIES
echo EXAMPLES_EXCLUDE=$EXAMPLES_EXCLUDE
echo EXAMPLES_BUILD_PROPERTIES=$EXAMPLES_BUILD_PROPERTIES

#echo HOME=$HOME # /github/home
#echo PWD=$PWD # /github/workspace
declare -p BASH_ARGV
#set
#ls -lR $PWD

#
# Download and install arduino IDE, if not already cached
#
echo -n -e "\n\n"$YELLOW"arduino-cli "
if [ -f $HOME/arduino_ide/arduino-cli ]; then
  echo -e "cached: ""$GREEN""\xe2\x9c\x93"
else
  echo -n "downloading: "
  wget --quiet https://downloads.arduino.cc/arduino-cli/arduino-cli_${CLI_VERSION}_Linux_64bit.tar.gz
  if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
  echo -n "Upacking arduino-cli to ${HOME}/arduino_ide:  "
  if [ ! -d $HOME/arduino_ide/ ]; then
    mkdir $HOME/arduino_ide
  fi
  tar xf arduino-cli_${CLI_VERSION}_Linux_64bit.tar.gz -C $HOME/arduino_ide/
  if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
#  ls -l $HOME/arduino_ide/* # LICENSE.txt + arduino-cli
#  ls -l $HOME # only arduino_ide
fi

#print version
$HOME/arduino_ide/arduino-cli version

# add the arduino CLI to our PATH
export PATH="$HOME/arduino_ide:$PATH"


#
# Link this repository as Arduino library
#
echo -e "\n\n"$YELLOW"Link this repository as Arduino library"
mkdir -p "$HOME/Arduino/libraries"
ln -s "$PWD" "$HOME/Arduino/libraries/."


#
# Update index and install the required board platform
#
echo -e "\n\n"$YELLOW"Update index and install the required board platform"
remainder=${ARDUINO_BOARD_FQBN#*:}; PLATFORM=${ARDUINO_BOARD_FQBN%%:*}:${remainder%%:*}
echo PLATFORM=${PLATFORM}
if [[ ${PLATFORM} != *"arduino"* && -z "$PLATFORM_URL" ]]; then
  echo -e "::error::Non Arduino platform $PLATFORM requested, but \"platform-url\" parameter is missing."
  exit 1
fi
if [ -z "$PLATFORM_URL" ]; then
  arduino-cli core update-index
  echo "arduino-cli core install $PLATFORM"
  arduino-cli core install $PLATFORM
else
  arduino-cli core update-index --additional-urls "$PLATFORM_URL" # must specify --additional-urls here
  echo -e "arduino-cli core install $PLATFORM --additional-urls \"$PLATFORM_URL\""
  arduino-cli core install $PLATFORM --additional-urls "$PLATFORM_URL"
fi

if [ "$PLATFORM" == "esp32:esp32" ]; then 
  pip install pyserial
fi

echo -e "\n\n"$YELLOW"List installed boards with their FQBN"
arduino-cli board listall


#
# Install libraries if needed
#
echo -e "\n\n"$YELLOW"Install libraries if needed"
if [ -z "$LIBRARIES" ]; then
  echo "No additional libraries to install"
else
  echo -n "Install libraries $LIBRARIES "
  # Support library names which contain whitespace
  declare -a -r LIBRARIES_ARRAY="(${LIBRARIES})"
  arduino-cli lib install "${LIBRARIES_ARRAY[@]}"
  if [ $? -ne 0 ]; then
    echo "::error::Installation of "$LIBRARIES" failed"
    exit 1
  fi
fi

#
# Finally, we compile all examples
#
echo -e "\n"$YELLOW"Compiling examples for board $ARDUINO_BOARD_FQBN \n"

# If matrix.examples-build-properties are specified, create an associative shell array
EXAMPLES_BUILD_PROPERTIES=${EXAMPLES_BUILD_PROPERTIES#\{} # remove the "{". The "}" is requred as end token
echo EXAMPLES_BUILD_PROPERTIES=$EXAMPLES_BUILD_PROPERTIES
if [[ $EXAMPLES_BUILD_PROPERTIES != "null" ]]; then 
  declare -A PROP_MAP="( $(echo $EXAMPLES_BUILD_PROPERTIES | sed -E 's/"(\w*)": *([^,}]*)[,}]/\[\1\]=\2/g' ) )"
else
  declare -A PROP_MAP=( [dummy]=dummy )
fi
declare -p PROP_MAP # print properties of PROP_MAP


EXAMPLES=($(find . -name "*.ino"))
for example in "${EXAMPLES[@]}"; do # Loop over all example directories
  EXAMPLE_NAME=$(basename $(dirname $example))
  if [[ "$EXAMPLES_EXCLUDE" == *"$EXAMPLE_NAME"* ]]; then
    echo -e "Skipping $EXAMPLE_NAME \xe2\x9e\x9e" # Right arrow
  else
    # check if there is an entry in the associative array and create a compile parameter
    echo -n "Compiling $EXAMPLE_NAME "
    if [[ "${PROP_MAP[$EXAMPLE_NAME]}" != "" ]]; then echo -n "with ${PROP_MAP[$EXAMPLE_NAME]} "; fi
    build_stdout=$(arduino-cli compile --verbose --warnings all --fqbn ${ARDUINO_BOARD_FQBN%|*} --build-properties compiler.cpp.extra_flags="${PROP_MAP[$EXAMPLE_NAME]}" $(dirname $example) 2>&1);
    if [ $? -ne 0 ]; then
      echo -e ""$RED"\xe2\x9c\x96" # If ok output a green checkmark else a red X and the command output.
      echo "::error::Compile of  $EXAMPLE_NAME ${PROP_MAP[$EXAMPLE_NAME]} failed"
      exit_code=1
      echo -e "$build_stdout \n"
    else
      echo -e ""$GREEN"\xe2\x9c\x93"
    fi
  fi
done
exit $exit_code
