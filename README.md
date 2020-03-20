# arduino-test-compile action

This action does a test-compile of one or more [Arduino programs](https://github.com/ArminJo/Arduino-Simple-DSO/actions) in a repository each with different compile parameters.<br/>
It can be used e.g. to test-compile all examples contained in an [Arduino library repository](https://github.com/ArminJo/NeoPatterns/actions).<br/>
It uses the [arduino-cli program](https://github.com/arduino/arduino-cli) for compiling.<br/>
It is not required, that the sketch resides in a directory with the same name (as Arduino IDE requires it). The appropriate directory is then created on the fly before test-compiling.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)
[![Build Status](https://github.com/ArminJo/Github-Actions/workflows/arduino-test-compile-Test/badge.svg)](https://github.com/ArminJo/Github-Actions/actions)

# Inputs
See [action.yml](https://github.com/ArminJo/arduino-test-compile/blob/master/action.yml) for comprehensive list of parameters.

### `cli-version`
The version of `arduino-cli` to use.<br/>
Default `latest`.

```yaml
cli-version: 0.9.0 # The current one (3/2020)
```

### `sketch-name`
Pattern or filename of the sketch(es) to test compile. Useful if the sketch is a *.cpp or *.c file or only one sketch in the repository should be compiled.<br/>
Default `*.ino`.

```yaml
sketch-name: SimpleTouchScreenDSO.cpp
```
if the sketch is not contained in a directory with the same name as the sketch, such a directory will be created and the content of the sketch directory will be recursively copied to it. This is required by the arduino-cli to successful compile a sketch.

### `arduino-board-fqbn`
The fully qualified board name to use when compiling.<br/>
Default `arduino:avr:uno`.<br/>

```yaml
arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
```
**For 3rd party boards**, you must also specify the Boards Manager URL `platform-url:`.

### `platform-url`
Required for 3rd party boards.

```yaml
arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
```

Sample URL's are:
- http://drazzy.com/package_drazzy.com_index.json - for ATTiny boards
- http://digistump.com/package_digistump_index.json - for Digispark boards
- http://arduino.esp8266.com/stable/package_esp8266com_index.json - for ESP8266 based boards
- https://dl.espressif.com/dl/package_esp32_index.json - for ESP32 based boards
- https://github.com/stm32duino/BoardManagerFiles/raw/dev/STM32/package_stm_index.json - for STM32 boards
- https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json - for Sparkfun boards, esp. Apollo3 boards
- https://files.pololu.com/arduino/package_pololu_index.json - for Pololu boards, esp. ATMega328PB boards

```yaml
platform-url: http://arduino.esp8266.com/stable/package_esp8266com_index.json
```

### `libraries`
List of library dependencies to install. Default `""`.
Space separated list without double quotes around the list. If you need a library with a space in its name, like Adafruit NeoPixel or Adafruit INA219, you must use double quotes around the name and have at least 2 entries, where the first must be without double quotes! You may use Servo as dummy entry.

```yaml
libraries: Servo "Adafruit NeoPixel"
```

#### `examples-exclude`
Examples to be **excluded from build**. Space separated list of (unique substrings of) example names to exclude in build.

```yaml
  examples-exclude: QuadrupedControl RobotArmControl # QuadrupedControl and RobotArmControl because of missing EEprom
```

#### `examples-build-properties`
Build parameter like `-DDEBUG` for each example

```yaml
  examples-build-properties: QuadrupedControl RobotArmControl # QuadrupedControl and RobotArmControl because of missing EEprom
```

# Workflows examples
## Simple - without any input
Compile all examples for the UNO board.

```yaml
name: SimpleLibraryBuild
on: push
jobs:
  build:
    name: Test compiling examples for UNO
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile all examples
      uses: actions/arduino-test-compile@master
```

## One ESP8266 board with parameter
```yaml
name: LibraryBuild
on: [push, pull_request]
jobs:
  build:
    name: Test compiling examples for esp8266
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@master
      
    - name: Compile all examples
      uses: actions/arduino-test-compile@master
      with:
        arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
        platform-url: http://arduino.esp8266.com/stable/package_esp8266com_index.json
        libraries: Servo "Adafruit NeoPixel"
        examples-exclude: WhistleSwitch 50Hz
```

## Multiple boards with parameter
```yaml
name: LibraryBuild
on: [push, pull_request]
jobs:
  build:
    name: ${{ matrix.arduino-boards-fqbn }} - test compiling examples
    runs-on: ubuntu-latest
    env:
      REQUIRED_LIBRARIES: Servo "Adafruit NeoPixel"
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|trace
          - esp8266:esp8266:huzzah:eesz=4M3M,xtal=80

        include:
          - arduino-boards-fqbn: arduino:avr:uno
            examples-exclude: 50Hz # Space separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DFREQUENCY_RANGE_LOW
              SimpleFrequencyDetector:
                -DINFO

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            examples-exclude: 50Hz # Space separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            platform-url: http://arduino.esp8266.com/stable/package_esp8266com_index.json
            examples-exclude: WhistleSwitch 50Hz SimpleFrequencyDetector          

      fail-fast: false
                
      steps:
      - name: Checkout
        uses: actions/checkout@master
      
      - name: Compile all examples
        uses: actions/arduino-test-compile@master
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-url: ${{ matrix.platform-url }}
          libraries: ${{ env.REQUIRED_LIBRARIES }}
          examples-exclude: ${{ matrix.examples-exclude }}
          examples-build-properties: ${{ toJson(matrix.examples-build-properties) }}
```

# Revision History
### Version 1.0.0
- Initial tested version

## Requests for modifications / extensions
Please write me a PM including your motivation/problem if you need a modification or an extension.

#### If you find this library useful, please give it a star.
