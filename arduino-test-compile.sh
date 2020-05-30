#!/bin/bash

# arduino-test-compile.sh
# Bash script to do a test-compile of one or more Arduino programs in a repository each with different compile parameters.
#
# Copyright (C) 2020  Armin Joachimsmeyer
# https://github.com/ArminJo/Github-Actions
# License: MIT
#

# Input parameter
CLI_VERSION="$1"
SKETCH_NAMES="$2"
SKETCH_NAMES_FIND_START="$3"
ARDUINO_BOARD_FQBN="$4"
ARDUINO_PLATFORM="$5"
PLATFORM_DEFAULT_URL="$6"
PLATFORM_URL="$7"
REQUIRED_LIBRARIES="$8"
EXAMPLES_EXCLUDE="$9"
EXAMPLES_BUILD_PROPERTIES="${10}"
DEBUG_COMPILE="${11}"
DEBUG_INSTALL="${12}" # not yet implemented for action

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'

#
# Get env parameter with higher priority, which enables the script to run directly in a step
#
if [[ -n $ENV_CLI_VERSION ]]; then CLI_VERSION=$ENV_CLI_VERSION; fi
if [[ -n $ENV_SKETCH_NAMES ]]; then SKETCH_NAMES=$ENV_SKETCH_NAMES; fi
if [[ -n $ENV_SKETCH_NAMES_FIND_START ]]; then SKETCH_NAMES_FIND_START=$ENV_SKETCH_NAMES_FIND_START; fi
if [[ -n $ENV_ARDUINO_BOARD_FQBN ]]; then ARDUINO_BOARD_FQBN=$ENV_ARDUINO_BOARD_FQBN; fi
if [[ -n $ENV_ARDUINO_PLATFORM ]]; then ARDUINO_PLATFORM=$ENV_ARDUINO_PLATFORM; fi
if [[ -n $ENV_PLATFORM_DEFAULT_URL ]]; then PLATFORM_DEFAULT_URL=$ENV_PLATFORM_DEFAULT_URL; fi
if [[ -n $ENV_PLATFORM_URL ]]; then PLATFORM_URL=$ENV_PLATFORM_URL; fi
if [[ -n $ENV_REQUIRED_LIBRARIES ]]; then REQUIRED_LIBRARIES=$ENV_REQUIRED_LIBRARIES; fi
if [[ -n $ENV_EXAMPLES_EXCLUDE ]]; then EXAMPLES_EXCLUDE=$ENV_EXAMPLES_EXCLUDE; fi
if [[ -n $ENV_EXAMPLES_BUILD_PROPERTIES ]]; then EXAMPLES_BUILD_PROPERTIES=$ENV_EXAMPLES_BUILD_PROPERTIES; fi
if [[ -n $ENV_DEBUG_COMPILE ]]; then DEBUG_COMPILE=$ENV_DEBUG_COMPILE; fi
if [[ -n $ENV_DEBUG_INSTALL ]]; then DEBUG_INSTALL=$ENV_DEBUG_INSTALL; fi


#
# Enforce defaults. Required at least for script version. !!! MUST be equal the defaults in action.yml !!!
#
echo -e "\n\n"$YELLOW"Set defaults"
if [[ -z $ARDUINO_BOARD_FQBN ]]; then echo "Set ARDUINO_BOARD_FQBN to default value: \"arduino:avr:uno\""; ARDUINO_BOARD_FQBN='arduino:avr:uno'; fi
if [[ -z $PLATFORM_URL && -n $PLATFORM_DEFAULT_URL ]]; then echo -e "Set PLATFORM_URL to default value: \"${PLATFORM_DEFAULT_URL}\""; PLATFORM_URL=$PLATFORM_DEFAULT_URL; fi
if [[ -z $CLI_VERSION ]]; then echo "Set CLI_VERSION to default value: \"latest\""; CLI_VERSION='latest'; fi
if [[ -z $SKETCH_NAMES ]]; then echo -e "Set SKETCH_NAMES to default value: \"*.ino\""; SKETCH_NAMES='*.ino'; fi
if [[ -z $SKETCH_NAMES_FIND_START ]]; then echo -e "Set SKETCH_NAMES_FIND_START to default value: \".\" (root of repository)"; SKETCH_NAMES_FIND_START='.'; fi


#
# Echo input parameter
#
echo -e "\n\n"$YELLOW"Echo input parameter"
echo CLI_VERSION=$CLI_VERSION
echo SKETCH_NAMES=$SKETCH_NAMES
echo SKETCH_NAMES_FIND_START=$SKETCH_NAMES_FIND_START
echo ARDUINO_BOARD_FQBN=$ARDUINO_BOARD_FQBN
echo ARDUINO_PLATFORM=$ARDUINO_PLATFORM
echo PLATFORM_DEFAULT_URL=$PLATFORM_DEFAULT_URL
echo PLATFORM_URL=$PLATFORM_URL
echo REQUIRED_LIBRARIES=$REQUIRED_LIBRARIES
echo EXAMPLES_EXCLUDE=$EXAMPLES_EXCLUDE
echo EXAMPLES_BUILD_PROPERTIES=$EXAMPLES_BUILD_PROPERTIES
echo DEBUG_COMPILE=$DEBUG_COMPILE
echo DEBUG_INSTALL=$DEBUG_INSTALL

#echo HOME=$HOME # /github/home
#echo PWD=$PWD # /github/workspace
#echo GITHUB_WORKSPACE=$GITHUB_WORKSPACE # /github/workspace
declare -p BASH_ARGV
#set
#ls -lR $GITHUB_WORKSPACE

#
# Download and install arduino IDE, if not already cached
#
echo -n -e "\n\n"$YELLOW"arduino-cli "
if [[ -f $HOME/arduino_ide/arduino-cli ]]; then
  echo -e "cached: ""$GREEN""\xe2\x9c\x93" # never seen :-(
else
  echo -n "downloading: "
  wget --quiet https://downloads.arduino.cc/arduino-cli/arduino-cli_${CLI_VERSION}_Linux_64bit.tar.gz
  if [[ $? -ne 0 ]]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
  echo -n "Upacking arduino-cli to ${HOME}/arduino_ide:  "
  if [[ ! -d $HOME/arduino_ide/ ]]; then
    mkdir $HOME/arduino_ide
  fi
  tar xf arduino-cli_${CLI_VERSION}_Linux_64bit.tar.gz -C $HOME/arduino_ide/
  if [[ $? -ne 0 ]]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
#  ls -l $HOME/arduino_ide/* # LICENSE.txt + arduino-cli
#  ls -l $HOME # only arduino_ide
fi

#print version
$HOME/arduino_ide/arduino-cli version

# add the arduino CLI to our PATH
export PATH="$HOME/arduino_ide:$PATH"

# Set debug flag for arduino-cli calls
if [[ $DEBUG_INSTALL == true ]]; then
  ARDUINO_VERBOSE=-v
else
  ARDUINO_VERBOSE=
fi

#
# Add *Custom* directories to Arduino library directory
#
if ls $GITHUB_WORKSPACE/*Custom* >/dev/null 2>&1; then
  echo -e "\n\n"${YELLOW}Add *Custom* as Arduino library
  mkdir -p "$HOME/Arduino/libraries"
  # mv to avoid the library examples to be test compiled
  mv -n -v $GITHUB_WORKSPACE/*Custom* "$HOME/Arduino/libraries/"
fi

#
# Link this repository as Arduino library
#
if [[ -f $GITHUB_WORKSPACE/library.properties ]]; then
  echo -e "\n\n"${YELLOW}Link this repository as Arduino library
  mkdir -p "$HOME/Arduino/libraries"
  ln -s "$GITHUB_WORKSPACE" "$HOME/Arduino/libraries/."
fi


#
# Update index and install the required board platform
#
echo -e "\n\n"${YELLOW}Update index and install the required board platform
if [[ -z $ARDUINO_PLATFORM ]]; then
  remainder=${ARDUINO_BOARD_FQBN#*:}; PLATFORM=${ARDUINO_BOARD_FQBN%%:*}:${remainder%%:*}
else
  PLATFORM=$ARDUINO_PLATFORM
fi
echo PLATFORM=${PLATFORM}
if [[ ${PLATFORM} != *arduino* && -z $PLATFORM_URL ]]; then
  echo -e "::error::Non Arduino platform $PLATFORM requested, but \"platform-url\" parameter is missing."
  exit 1
fi

if [[ -n $PLATFORM_URL ]]; then
  PLATFORM_URL=${PLATFORM_URL// /,} # replace space by comma to enable multiple urls which are space separated
  PLATFORM_URL_COMMAND="--additional-urls"
fi

PLATFORM=${PLATFORM//,/ } # replace all comma by space to enable multiple platforms which are comma separated
declare -a PLATFORM_ARRAY=( $PLATFORM )
#declare -p PLATFORM_ARRAY # print properties of PLATFORM_ARRAY
for single_platform in "${PLATFORM_ARRAY[@]}"; do # Loop over all platforms specified
  if [[ $DEBUG_INSTALL == true ]]; then
    echo -e "arduino-cli core update-index $PLATFORM_URL_COMMAND $PLATFORM_URL $ARDUINO_VERBOSE"
    arduino-cli core update-index $PLATFORM_URL_COMMAND $PLATFORM_URL $ARDUINO_VERBOSE # must specify --additional-urls here
    echo -e "arduino-cli core install $single_platform $PLATFORM_URL_COMMAND $PLATFORM_URL $ARDUINO_VERBOSE"
    arduino-cli core install $single_platform $PLATFORM_URL_COMMAND $PLATFORM_URL $ARDUINO_VERBOSE
  else
    echo -e "arduino-cli core update-index $PLATFORM_URL_COMMAND $PLATFORM_URL > /dev/null"
    arduino-cli core update-index $PLATFORM_URL_COMMAND $PLATFORM_URL > /dev/null # must specify --additional-urls here
    echo -e "arduino-cli core install $single_platform $PLATFORM_URL_COMMAND $PLATFORM_URL > /dev/null"
    arduino-cli core install $single_platform $PLATFORM_URL_COMMAND $PLATFORM_URL > /dev/null
  fi
done

if [[ ${PLATFORM} == esp8266:esp8266 && ! -f /usr/bin/python3 ]]; then
  # python3 is a link in the esp8266 package: /github/home/.arduino15/packages/esp8266/tools/python3/3.7.2-post1/python3 -> /usr/bin/python3
  echo -e "\n\n"${YELLOW}install python3 for ESP8266
  apt-get install -qq python3 > /dev/null
fi

if [[ $PLATFORM == esp32:esp32 ]]; then
  if [[ ! -f /usr/bin/pip && ! -f /usr/bin/python ]]; then
    echo -e "\n\n"${YELLOW}install python and pip for ESP32
# Here we would get the warning: The directory '/github/home/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled.
#                                Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
    apt-get install -qq python-pip > /dev/null 2>&1 # this installs also python
  fi
  pip install pyserial
fi

echo -e "\n\n"$YELLOW"List installed boards with their FQBN"
arduino-cli board listall $ARDUINO_VERBOSE


#
# Install required libraries
#
echo -e "\n"$YELLOW"Install required libraries"
if [[ -z $REQUIRED_LIBRARIES ]]; then
  echo "No additional libraries to install"
else
  echo "Install libraries $REQUIRED_LIBRARIES"
  BACKUP_IFS="$IFS"
  # Split comma separated library list
  IFS=$','
  declare -a REQUIRED_LIBRARIES_ARRAY=( $REQUIRED_LIBRARIES )
  IFS="$BACKUP_IFS"
  arduino-cli lib install "${REQUIRED_LIBRARIES_ARRAY[@]}"
  if [[ $? -ne 0 ]]; then
    echo "::error::Installation of "$REQUIRED_LIBRARIES" failed"
    exit 1
  fi
fi


#
# Get the build property map
#
echo -e "\n"$YELLOW"Compiling sketches / examples for board $ARDUINO_BOARD_FQBN \n"

# If matrix.examples-build-properties are specified, create an associative shell array
if [[ -n $EXAMPLES_BUILD_PROPERTIES && $EXAMPLES_BUILD_PROPERTIES != "null" ]]; then # contains "null", if passed as environment variable
  echo EXAMPLES_BUILD_PROPERTIES=$EXAMPLES_BUILD_PROPERTIES
  EXAMPLES_BUILD_PROPERTIES=${EXAMPLES_BUILD_PROPERTIES#\{} # remove the "{". The "}" is required as end token
  declare -A PROP_MAP="( $(echo $EXAMPLES_BUILD_PROPERTIES | sed -E 's/"(\w*)": *([^,}]*)[,}]/\[\1\]=\2/g' ) )"
  declare -p PROP_MAP # print properties of PROP_MAP
else
  declare -A PROP_MAP=( [dummy]=dummy )
fi

#
# Finally, we compile all examples
#
# Split comma separated sketch name list
BACKUP_IFS="$IFS"
IFS=$','
SKETCH_NAMES=${SKETCH_NAMES// /}
declare -a SKETCH_NAMES_ARRAY=( $SKETCH_NAMES )
#declare -p SKETCH_NAMES_ARRAY
IFS="$BACKUP_IFS"
for sketch_name in "${SKETCH_NAMES_ARRAY[@]}"; do # Loop over all sketch names
  declare -a SKETCHES=($(find ${SKETCH_NAMES_FIND_START} -type f -name "$sketch_name")) # only search for files
  #declare -p SKETCHES
  for sketch in "${SKETCHES[@]}"; do # Loop over all sketch files
    SKETCH_PATH=$(dirname $sketch) # complete path to sketch
    SKETCH_DIR=${SKETCH_PATH##*/}  # directory of sketch, must match sketch basename
    SKETCH_FILENAME=$(basename $sketch) # complete name of sketch
    SKETCH_EXTENSION=${SKETCH_FILENAME##*.} # extension of sketch
    SKETCH_BASENAME=${SKETCH_FILENAME%%.*} # name wihout extension / basename of sketch, must match directory name
    if [[ $EXAMPLES_EXCLUDE == *"$SKETCH_BASENAME"* ]]; then
      echo -e "Skipping $SKETCH_BASENAME \xe2\x9e\x9e" # Right arrow
    else
      # If sketch name does not end with .ino, rename it locally
      if [[ $SKETCH_EXTENSION != ino ]]; then
        echo "Rename ${SKETCH_PATH}/${SKETCH_FILENAME} to ${SKETCH_PATH}/${SKETCH_BASENAME}.ino"
        mv ${SKETCH_PATH}/${SKETCH_FILENAME} ${SKETCH_PATH}/${SKETCH_BASENAME}.ino
      fi
      # If directory name does not match sketch name, create an appropriate directory, copy the files recursively and compile
      if [[ $SKETCH_DIR != $SKETCH_BASENAME ]]; then
        mkdir $HOME/$SKETCH_BASENAME
        echo "Creating directory $HOME/$SKETCH_BASENAME and copy ${SKETCH_PATH}/* to it"
        cp -R ${SKETCH_PATH}/* $HOME/$SKETCH_BASENAME
        SKETCH_PATH=$HOME/$SKETCH_BASENAME
      fi
      # check if there is an entry in the associative array and create compile parameter to put in compiler.cpp.extra_flags
      echo -n "Compiling $SKETCH_BASENAME "
      if [[ -n ${PROP_MAP[$SKETCH_BASENAME]} ]]; then
        CPP_EXTRA_FLAGS=${PROP_MAP[$SKETCH_BASENAME]}
        echo -n "with $CPP_EXTRA_FLAGS "
      elif [[ -n ${PROP_MAP[All]} ]]; then
        CPP_EXTRA_FLAGS=${PROP_MAP[All]}
        echo -n "with $CPP_EXTRA_FLAGS "
      else
        CPP_EXTRA_FLAGS=
      fi
        build_stdout=$(arduino-cli compile --verbose --warnings all --fqbn ${ARDUINO_BOARD_FQBN%|*} --build-properties compiler.cpp.extra_flags="${CPP_EXTRA_FLAGS}" $SKETCH_PATH 2>&1)
      if [[ $? -ne 0 ]]; then
        echo -e ""$RED"\xe2\x9c\x96" # If ok output a green checkmark else a red X and the command output.
        echo "arduino-cli compile --verbose --warnings all --fqbn ${ARDUINO_BOARD_FQBN%|*} --build-properties compiler.cpp.extra_flags=\"${CPP_EXTRA_FLAGS}\" $SKETCH_PATH"
        echo "::error::Compile of  $SKETCH_BASENAME ${CPP_EXTRA_FLAGS} failed"
        echo -e "$build_stdout \n"
        exit_code=1
      else
        echo -e ""$GREEN"\xe2\x9c\x93"
        echo "arduino-cli compile --verbose --warnings all --fqbn ${ARDUINO_BOARD_FQBN%|*} --build-properties compiler.cpp.extra_flags=\"${CPP_EXTRA_FLAGS}\" $SKETCH_PATH"
        if [[ $DEBUG_COMPILE == true ]]; then
          echo "Debug mode enabled => compile output will be printed also for successful compilation"
          echo -e "$build_stdout \n"
        fi
      fi
    fi
  done
done
exit $exit_code
