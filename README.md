# arduino-test-compile [action](https://github.com/marketplace/actions/test-compile-for-arduino) / script

This action does a test-compile of one or more [Arduino programs](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master/src) in a repository for different boards, each with different compile parameters.<br/>
It can be used e.g. to test-compile all examples contained in an [Arduino library repository](https://github.com/ArminJo/NeoPatterns/tree/master/examples).<br/>
The action is a Docker action which uses the [arduino-cli program](https://github.com/arduino/arduino-cli) for compiling. All the other work is done by the [arduino-test-compile.sh](https://github.com/ArminJo/arduino-test-compile/blob/master/arduino-test-compile.sh) bash script.<br/>
If you want to test compile a sketch, it is not required that the sketch resides in a directory with the same name (as Arduino IDE requires it) or has the extension .ino. Internally the appropriate directory is created on the fly for test-compiling and the file is renamed to be .ino.

If you need more flexibility for e.g. installing additional board platforms, or want to save around 20 to 30 seconds for each job, then you may want to
use the [arduino-test-compile.sh](https://github.com/ArminJo/arduino-test-compile/blob/master/arduino-test-compile.sh) directly.
See [example below](https://github.com/ArminJo/arduino-test-compile#multiple-boards-with-parameter-using-the-script-directly).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)
[![Build Status](https://github.com/ArminJo/arduino-test-compile/workflows/arduino-test-compile-ActionTest/badge.svg)](https://github.com/ArminJo/arduino-test-compile/actions)
[![Build Status](https://github.com/ArminJo/arduino-test-compile/workflows/arduino-test-compile-ScriptTest/badge.svg)](https://github.com/ArminJo/arduino-test-compile/actions)

# Inputs
See [action.yml](https://github.com/ArminJo/arduino-test-compile/blob/master/action.yml) for comprehensive list of parameters.

### `arduino-board-fqbn`
The fully qualified board name to use for compiling with arduino-cli.<br/>
Default `arduino:avr:uno`<br/>
Environment name for script usage `ENV_ARDUINO_BOARD_FQBN`

```yaml
arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
```
**For 3rd party boards**, you must also specify the Boards Manager URL `platform-url:`.

### `platform-url`
Required for 3rd party boards. If you need, you may specify more than one URL as a comma separated list (without enclosing it in double quotes) like `http://drazzy.com/package_drazzy.com_index.json,https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json`
Default `""`<br/>
Environment name for script usage `ENV_PLATFORM_URL`

```yaml
platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

Sample URL's are:
- http://drazzy.com/package_drazzy.com_index.json - for ATTiny boards
- Old URL: http://digistump.com/package_digistump_index.json - for Digispark boards. https gives: x509: certificate signed by unknown authority
- Improved URL: https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json - up to 20% more code possible
- https://arduino.esp8266.com/stable/package_esp8266com_index.json - for ESP8266 based boards
- https://dl.espressif.com/dl/package_esp32_index.json - for ESP32 based boards
- https://github.com/stm32duino/BoardManagerFiles/raw/dev/STM32/package_stm_index.json - for STM32 boards
- https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json - for Sparkfun boards, esp. Apollo3 boards
- https://files.pololu.com/arduino/package_pololu_index.json - for Pololu boards, esp. ATMega328PB boards


### `required-libraries`
Comma separated list of library dependencies to install. You may add a version number like `@1.3.4`<br/>
Default `""`<br/>
Environment name for script usage `ENV_REQUIRED_LIBRARIES`

```yaml
required-libraries: Servo,Adafruit NeoPixel@1.3.4
```

Space separated list without double quotes around the list. If you need a library with a space in its name, like Adafruit NeoPixel or Adafruit INA219, you must use double quotes around the name and have at least 2 entries, where the first must be without double quotes! You may use Servo as dummy entry.


### `examples-exclude`
Examples to be **excluded from build**. Comma or space separated list of (unique substrings of) sketch / example names to exclude in build.<br/>
Environment name for script usage `ENV_EXAMPLES_EXCLUDE`

```yaml
  examples-exclude: QuadrupedControl,RobotArmControl # QuadrupedControl and RobotArmControl because of missing EEprom
```

### `examples-build-properties`
Build parameter like `-DDEBUG` for each example<br/>
Environment name for script usage `ENV_EXAMPLES_BUILD_PROPERTIES`<br/>

In the `include:` section you may specify:
```yaml
include:
  examples-build-properties:
    WhistleSwitch:
      -DDEBUG
      -DFREQUENCY_RANGE_LOW
    SimpleFrequencyDetector:
      -DINFO
```
in the `with:` section it must be:

```yaml
with:
  examples-build-properties: '{ "WhistleSwitch": "-DDEBUG -DFREQUENCY_RANGE_LOW", "SimpleFrequencyDetector": "-DINFO" }'
```

### `cli-version`
The version of `arduino-cli` to use.<br/>
Default `latest`<br/>
Environment name for script usage `ENV_CLI_VERSION`

```yaml
cli-version: 0.9.0 # The current one (3/2020)
```

### `sketch-names`
Comma sepatated list of patterns or filenames (without path) of the sketch(es) to test compile. Useful if the sketch is a *.cpp or *.c file or only one sketch in the repository should be compiled. If first is a `*` the list must be enclosed in double quotes!<br/>
Default `*.ino`<br/>
Environment name for script usage `ENV_SKETCH_NAMES`

```yaml
sketch-names: "*.ino,SimpleTouchScreenDSO.cpp"
```
If the sketch is not contained in a directory with the same name as the sketch, this directory will be created internally and the content of the sketch directory will be recursively copied to it. This is required by arduino-cli to successful compile a sketch.<br/>
The sketches to compile are internally searched by the command `find . -name "$SKETCH_NAME"` with `.` as the root of the repository, so you do not need to specify the full path.

### `arduino-platform`
Comma separated list of platform specifies with optional version. Useful if you require multiple platforms for your board or a fixed version like `arduino:avr@1.8.2`.<br/>
In general, use it if you require another specifier than the one derived from the 2 first elements of the arduino-board-fqbn e.g. **esp8266:esp8266**:huzzah:eesz=4M3M,xtal=80, esp32:esp32:featheresp32:FlashFreq=80 -> **esp8266:esp8266**<br/>
Environment name for script usage `ENV_ARDUINO_PLATFORM`

```yaml
arduino-platform: arduino:avr@1.8.2,digistump:avr
```

# Workflows examples
## Simple - without any parameter
Compile all sketches / examples for the UNO board.

```yaml
name: SimpleBuild
on: push
jobs:
  build:
    name: Test compiling examples for UNO
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@master
    - name: Compile all examples
      uses: ArminJo/arduino-test-compile@v2.0.0
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
        uses: ArminJo/arduino-test-compile@v2.0.0
      with:
        arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
        platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
        required-libraries: Servo,Adafruit NeoPixel
        examples-exclude: WhistleSwitch 50Hz
        examples-build-properties: '{ "WhistleSwitch": "-DDEBUG -DFREQUENCY_RANGE_LOW", "SimpleFrequencyDetector": "-DINFO" }'        
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
      REQUIRED_LIBRARIES: Servo,Adafruit NeoPixel
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|trace
          - esp8266:esp8266:huzzah:eesz=4M3M,xtal=80

        include:
          - arduino-boards-fqbn: arduino:avr:uno
            sketch-names: "*.ino" # is default setting
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DFREQUENCY_RANGE_LOW
              SimpleFrequencyDetector:
                -DINFO

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
            examples-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector          

      fail-fast: false
                
      steps:
      - name: Checkout
        uses: actions/checkout@master
      
      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v2.0.0
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-url: ${{ matrix.platform-url }}
          required-libraries: ${{ env.REQUIRED_LIBRARIES }}
          examples-exclude: ${{ matrix.examples-exclude }}
          examples-build-properties: ${{ toJson(matrix.examples-build-properties) }}
```

## Multiple boards with parameter using the script directly
This is faster and more flexible.

```yaml
name: LibraryBuild
on: [push, pull_request]
jobs:
  build:
    name: ${{ matrix.arduino-boards-fqbn }} - test compiling examples
    runs-on: ubuntu-latest
    env:
      REQUIRED_LIBRARIES: Adafruit NeoPixel,Servo
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|trace
          - esp8266:esp8266:huzzah:eesz=4M3M,xtal=80

        include:
          - arduino-boards-fqbn: arduino:avr:uno
            sketch-names: WhistleSwitch.ino,SimpleFrequencyDetector.ino # Comma separated list of sketch names (no path required) or patterns to use in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DFREQUENCY_RANGE_LOW
              SimpleFrequencyDetector:
                -DINFO

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
            examples-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector          

      fail-fast: false
      steps:
      - name: Checkout
        uses: actions/checkout@master
      - name: Compile all examples using the bash script arduino-test-compile.sh
        env:
          # Passing parameters to the script by setting the appropriate ENV_* variables.
          ENV_ARDUINO_BOARD_FQBN: ${{ matrix.arduino-boards-fqbn }}
          ENV_PLATFORM_URL: ${{ matrix.platform-url }}
          ENV_REQUIRED_LIBRARIES: ${{ env.REQUIRED_LIBRARIES }}
          ENV_EXAMPLES_EXCLUDE: ${{ matrix.examples-exclude }}
          ENV_EXAMPLES_BUILD_PROPERTIES: ${{ toJson(matrix.examples-build-properties) }}
        run: |
          wget --quiet https://raw.githubusercontent.com/ArminJo/arduino-test-compile/master/arduino-test-compile.sh
          chmod +x arduino-test-compile.sh
          ./arduino-test-compile.sh
```
            
Samples for using action in workflow:
- The simple example from above. LightweightServo [![Build Status](https://github.com/ArminJo/LightweightServo/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/LightweightServo/blob/master/.github/workflows/LibraryBuild.yml)
- One sketch, one library. Simple-DSO [![Build Status](https://github.com/ArminJo/Arduino-Simple-DSO/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-Simple-DSO/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, only arduino:avr boards. Talkie [![Build Status](https://github.com/ArminJo/Talkie/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/Talkie/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, 2 boards. Arduino-FrequencyDetector [![Build Status](https://github.com/ArminJo/Arduino-FrequencyDetector/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/Arduino-FrequencyDetector/blob/master/.github/workflows/LibraryBuildWithAction.yml)

Samples for using `arduino-test-compile.sh script` instead of `ArminJo/arduino-test-compile@v2.0.0` action:
- One sketch, one board, multiple options. RobotCar [![Build Status](https://github.com/ArminJo/Arduino-RobotCar/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-RobotCar/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, multiple boards. ServoEasing [![Build Status](https://github.com/ArminJo/ServoEasing/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/ServoEasing/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, multiple boards. NeoPatterns [![Build Status](https://github.com/ArminJo/NeoPatterns/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/NeoPatterns/blob/master/.github/workflows/LibraryBuild.yml)

# Revision History
### Version 2.0.0
- Changed `required-libraries` from **space** to **comma** separated list.
- Renamed parameter `sketch-name` to `sketch-names` to enable comma separated list.
- Accept comma separated list for `examples-exclude`.
- Updated documentation. 

### Version 1.1.0
- Renamed parameter `libraries` to `required-libraries`.
- Renamed script.
- Script instead of action can be used in steps.
- Added parameter `arduino-platform` to enable specifying the version of the required platform.

### Version 1.0.0
- Initial tested version.

## Requests for modifications / extensions
Please write me a PM including your motivation/problem if you need a modification or an extension.

#### If you find this action useful, please give it a star.
