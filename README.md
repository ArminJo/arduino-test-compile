# arduino-compile-examples action

This action uses the arduino-cli to compiles all of the examples contained in the library.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)


# Inputs
See action.yml for comprehensive list of parameters.

### `cli-version`
The version of `arduino-cli` to use. Default `latest`.

### `arduino-board-fqbn`
The fully qualified board name to use when compiling. Default `arduino:avr:uno`.<br/>
For 3rd party boards, you must also specify the Boards Manager URL `platform-url:`.

### `platform-url`
Required for 3rd party boards.<br/>
Sample URL's are:
- http://drazzy.com/package_drazzy.com_index.json
- http://digistump.com/package_digistump_index.json
- http://arduino.esp8266.com/stable/package_esp8266com_index.json
- https://dl.espressif.com/dl/package_esp32_index.json
- https://github.com/stm32duino/BoardManagerFiles/raw/dev/STM32/package_stm_index.json
- https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json
- https://files.pololu.com/arduino/package_pololu_index.json

```yaml
platform-url: http://arduino.esp8266.com/stable/package_esp8266com_index.json
```

### `libraries`
List of library dependencies to install. Default `""`.
Space separated list without double quotes around the list. If you need a library with a space in its name, like Adafruit NeoPixel or Adafruit INA219, you must use double quotes around the name and have at least 2 entries, where the first must be without double quotes! You may use Servo as dummy entry.

#### `examples-exclude`
Examples to be **excluded from build**. Space separated list of (unique substrings of) example names to exclude in build.

```yaml
  examples-exclude: QuadrupedControl RobotArmControl # QuadrupedControl and RobotArmControl because of missing EEprom
```

#### `examples-build-properties`
Build parameter like `-DDEBUG` for each example

# Workflows examples
## Simple - without any input
Compile all examples for the UNO board.

```yaml
name: LibraryBuild
on: push
jobs:
  build:
    name: Test compiling examples for UNO
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile all examples
      uses: ArminJo/arduino-compile-examples@master
```

## One board with parameter
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
      uses: ArminJo/arduino-compile-examples@master
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
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|trace
          - esp8266:esp8266:huzzah:eesz=4M3M,xtal=80

        include:
          - arduino-boards-fqbn: arduino:avr:uno
            examples-exclude: 50Hz # Space separated list of (unique substrings of) example names to exclude in build
            SimpleFrequencyDetector: -DDEBUG
            WhistleSwitch: -DINFO
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG

          - arduino-boards-fqbn: arduino:avr:uno|trace
            examples-exclude: 50Hz # Space separated list of (unique substrings of) example names to exclude in build
            SimpleFrequencyDetector: -DTRACE
            WhistleSwitch: -DTRACE
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
        uses: actions/arduino-compile-examples@master
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-url: ${{ matrix.platform-url }}
          libraries: ${{ env.REQUIRED_LIBRARIES }}
          examples-exclude: ${{ matrix.examples-exclude }}
          examples-build-properties: ${{ toJson(matrix.examples-build-properties) }}
```
