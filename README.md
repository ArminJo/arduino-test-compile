# arduino-test-compile [action](https://github.com/marketplace/actions/test-compile-for-arduino) / script
### Version 2.5.0

This action does a test-compile of one or more [Arduino programs](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master) in a repository for different boards, each with different compile parameters.<br/>
It can be used e.g. to test-compile all examples contained in an [Arduino library repository](https://github.com/ArminJo/NeoPatterns/tree/master/examples).<br/>
The action is a Docker action which uses Ubuntu 18.04 and the [arduino-cli program](https://github.com/arduino/arduino-cli) for compiling. All the other work like loading libraries, installing board definitions and setting parameters is orchestrated by the [arduino-test-compile.sh](arduino-test-compile.sh) bash script.<br/>
In case of a compile error the [**complete compile output**](https://github.com/ArminJo/PlayRtttl/runs/692586646?check_suite_focus=true#step:4:99) is logged in the [Compile all examples](https://github.com/ArminJo/PlayRtttl/runs/692586646?check_suite_focus=true#step:4:1) step, otherwise only a [**green check**](https://github.com/ArminJo/PlayRtttl/runs/692736061?check_suite_focus=true#step:4:95) is printed.<br/>
If you want to test compile a sketch, **it is not required that the sketch resides in a directory with the same name (as Arduino IDE requires it) or has the extension .ino**. Internally the file is renamed to be .ino and the appropriate directory is created on the fly at `/home/runner/<sketch-name>` for test-compiling. See [parameter `sketch-names`](arduino-test-compile#sketch-names).<br/>

If you need more flexibility for e.g. installing additional board platforms, or want to save around 20 to 30 seconds for each job, then you may consider to
use the [arduino-test-compile.sh](https://github.com/ArminJo/arduino-test-compile/blob/master/arduino-test-compile.sh) directly.
See [example below](https://github.com/ArminJo/arduino-test-compile#multiple-boards-with-parameter-using-the-script-directly).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)
[![Build Status](https://github.com/ArminJo/arduino-test-compile/workflows/arduino-test-compile-ActionTest/badge.svg)](https://github.com/ArminJo/arduino-test-compile/actions)
[![Build Status](https://github.com/ArminJo/arduino-test-compile/workflows/arduino-test-compile-ScriptTest/badge.svg)](https://github.com/ArminJo/arduino-test-compile/actions)

# Inputs
See [action.yml](https://github.com/ArminJo/arduino-test-compile/blob/master/action.yml) for comprehensive list of parameters.

### `arduino-board-fqbn`
The fully qualified board name to use for compiling with arduino-cli. You may add a suffix behind the fqbn with `|` to specify one board for e.g. different compile options like `arduino:avr:uno|trace`.<br/>
Default is `arduino:avr:uno`.<br/>
Environment name for script usage is `ENV_ARDUINO_BOARD_FQBN`.

```yaml
arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
```

**For 3rd party boards**, you must also specify the Boards Manager URL `platform-default-url:` or `platform-url:`.

### `platform-default-url`
Default value to take, if `platform-url` is not specified for a 3rd party board. Useful, if you want to test compile for different boards types of one architecture.<br/>
Default is `""`.<br/>
Environment name for script usage is `ENV_PLATFORM_DEFAULT_URL`.

```yaml
platform-default-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

### `platform-url`
Required for 3rd party boards, if `platform-default-url` is not specified or applicable. If you need, you may specify more than one URL as a comma separated list (without enclosing it in double quotes) like `http://drazzy.com/package_drazzy.com_index.json,https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json`.<br/>
Default is `""`.<br/>
Environment name for script usage is `ENV_PLATFORM_URL`.

```yaml
  platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

Sample URL's are:
- http://drazzy.com/package_drazzy.com_index.json - for ATTiny boards
- https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json - for Digistump AVR boards. Up to 20% smaller code
- https://arduino.esp8266.com/stable/package_esp8266com_index.json - for ESP8266 based boards
- https://dl.espressif.com/dl/package_esp32_index.json - for ESP32 based boards
- https://github.com/stm32duino/BoardManagerFiles/raw/master/STM32/package_stm_index.json - for STM32 boards
- https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json - for Sparkfun boards, esp. Apollo3 boards
- https://files.pololu.com/arduino/package_pololu_index.json - for Pololu boards, esp. ATMega328PB boards
- https://downloads.arduino.cc/packages/package_index.json - Built in URL for default Arduino boards, not required to specify

### `arduino-platform`
Comma separated list of platform specifies with optional version to specify multiple platforms for your board or a fixed version like `arduino:avr@1.8.2`.<br/>
In general, use it only if you require another specifier than the one derived from the 2 first elements of the arduino-board-fqbn e.g. **esp8266:esp8266**:huzzah:eesz=4M3M,xtal=80, esp32:esp32:featheresp32:FlashFreq=80 -> **esp8266:esp8266**. Do not forget to specify the related URL's, if it is not the arduino URL, which is built in.<br/>
Default is `""`.<br/>
Environment name for script usage is `ENV_ARDUINO_PLATFORM`.

```yaml
arduino-platform: arduino:avr,SparkFun:avr@1.1.13
platform-url: https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json # Arduino URL is not required here

```

### `required-libraries`
Comma separated list of arduino library dependencies to install. You may add a version number like `@1.3.4`.<br/>
Only libraries [avaliable in the Arduino library manager](https://www.arduinolibraries.info/) can be installed this way.<br/>
To use other/custom libraries, you must put all the library files into the sketch directory or add an extra step as in [this example](#using-custom-library).
Default is `""`.<br/>
Environment name for script usage is `ENV_REQUIRED_LIBRARIES`.

```yaml
required-libraries: Servo,Adafruit NeoPixel@1.3.4
```

Comma separated list without double quotes around the list or a library name. A list of correct library names can be found [here](https://www.arduinolibraries.info/).


### `examples-exclude`
Examples to be **excluded from build**. Comma or space separated list of (unique substrings of) sketch / example names to exclude in build.<br/>
Environment name for script usage is `ENV_EXAMPLES_EXCLUDE`.

```yaml
  examples-exclude: QuadrupedControl,RobotArmControl # QuadrupedControl and RobotArmControl because of missing EEprom
```

### `examples-build-properties`
Build parameter like `-DDEBUG` for each example specified or for all examples, if example name is `All`. If an example specific parameter is specified, the value for All is ignored for this example. <br/>
Environment name for script usage is `ENV_EXAMPLES_BUILD_PROPERTIES`.<br/>

In the `include:` section you may specify:

```yaml
include:
...
  examples-build-properties:
    WhistleSwitch:
      -DDEBUG
      -DFREQUENCY_RANGE_LOW
    SimpleFrequencyDetector:
      -DINFO
...
  examples-build-properties:
    All:
      -DDEBUG
...
```

and reference it in the `with:` section by: 

```yaml
with:
  examples-build-properties: ${{ toJson(matrix.examples-build-properties) }}
```

If you want to specify it directly in the `with:` section it must be:

```yaml
with:
  examples-build-properties: '{ "WhistleSwitch": "-DDEBUG -DFREQUENCY_RANGE_LOW", "SimpleFrequencyDetector": "-DINFO", "All": "-DDEBUG" }'
```

### `cli-version`
The version of `arduino-cli` to use.<br/>
Default is `latest`.<br/>
Environment name for script usage is `ENV_CLI_VERSION`.

```yaml
cli-version: 0.9.0 # The current one (3/2020)
```

### `sketch-names`
Comma sepatated list of patterns or filenames (without path) of the sketch(es) to test compile. Useful if the sketch is a *.cpp or *.c file or only one sketch in the repository should be compiled. If first character is a `*` like in "*.ino" the list must be enclosed in double quotes!<br/>
The **sketch names to compile are searched in the whole repository** by the command `find . -name "$SKETCH_NAME"` with `.` as the root of the repository, so you do not need to specify the full path.<br/>
If you specify `sketch-names-find-start` then the find command is changed to `find ${PWD}/${SKETCH_NAMES_FIND_START} -name "$SKETCH_NAME"`.<br/>
Sketches do not need to be in an example directory. This enables **[plain programs](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master) to be test compiled**.<br/>
Since Arduino requires a sketch to end with .ino and to reside in a directory with the same name as the sketch, if required, the **renaming and directory creation is done internally** to fulfill the requirements of the Arduino IDE.<br/>
Default is `*.ino`.<br/>
Environment name for script usage is `ENV_SKETCH_NAMES`.

```yaml
sketch-names: "*.ino,SimpleTouchScreenDSO.cpp"
```

### `sketch-names-find-start`
The **start directory to look for the sketch-names** to test compile. Can be a path like `digistump-avr/libraries/*/examples/`. Must be a path **relative to the root of the repository**. Used [here](https://github.com/ArminJo/DigistumpArduino/blob/master/.github/workflows/TestCompile.yml) to compile all library examples of the board package.
Default is `.` (root of repository).<br/>
Environment name for script usage is `ENV_SKETCH_NAMES_FIND_START`.

```yaml
sketch-names-find-start: digistump-avr/libraries/*/examples/C*/
```

### `save-generated-files`
If set to true, the **generated files** (.bin, .hex, .elf etc.) can be found in the example directory `/home/runner/work/<repo-name>/<repo-name>/src/<example_name>` = `$GITHUB_WORKSPACE/src/<example_name>`  or in `/home/runner/<sketch-name>` = `$HOME/<sketch-name>` for files not residing in a directory with the same name.<br/>
Because of an [arduino-cli bug](https://github.com/arduino/arduino-cli/issues/821) this function is **incompatible with examples having local *.h files**.
Default is `false` (compatible with local *.h files).<br/>
Environment name for script usage is `ENV_SAVE_GENERATED_FILES`.

```yaml
save-generated-files: true
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
      uses: actions/checkout@v2
    - name: Compile all examples
      uses: ArminJo/arduino-test-compile@v2
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
      uses: actions/checkout@v2

    - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v2
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
on:
  push: # see: https://help.github.com/en/actions/reference/events-that-trigger-workflows#pull-request-event-pull_request
    paths:
    - '**.ino'
    - '**.cpp'
    - '**.h'
    - '**LibraryBuild.yml'
  pull_request:
jobs:
  build:
    name: ${{ matrix.arduino-boards-fqbn }} - test compiling examples
    runs-on: ubuntu-latest
    env:
      PLATFORM_DEFAULT_URL: https://arduino.esp8266.com/stable/package_esp8266com_index.json
      REQUIRED_LIBRARIES: Servo,Adafruit NeoPixel
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|All-DEBUG
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

          - arduino-boards-fqbn: arduino:avr:uno|All-DEBUG # UNO board with -DDEBUG for all examples
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              All:
                -DDEBUG

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            examples-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector

      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v2
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-default-url: ${{ env.PLATFORM_DEFAULT_URL }}
          platform-url: ${{ matrix.platform-url }}
          required-libraries: ${{ env.REQUIRED_LIBRARIES }}
          sketch-names: ${{ matrix.sketch-names }}
          examples-exclude: ${{ matrix.examples-exclude }}
          examples-build-properties: ${{ toJson(matrix.examples-build-properties) }}
```

## Multiple boards with parameter using the **script directly**
This is faster and more flexible.

```yaml
name: LibraryBuild
on:
  push: # see: https://help.github.com/en/actions/reference/events-that-trigger-workflows#pull-request-event-pull_request
    paths:
    - '**.ino'
    - '**.cpp'
    - '**.h'
    - '**LibraryBuild.yml'
  pull_request:
jobs:
  build:
    name: ${{ matrix.arduino-boards-fqbn }} - test compiling examples
    runs-on: ubuntu-latest
    env:
      PLATFORM_DEFAULT_URL: https://arduino.esp8266.com/stable/package_esp8266com_index.json
      REQUIRED_LIBRARIES: Adafruit NeoPixel,Servo
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno
          - arduino:avr:uno|All-DEBUG
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

          - arduino-boards-fqbn: arduino:avr:uno|All-DEBUG # UNO board with -DDEBUG for all examples
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              All:
                -DDEBUG

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            examples-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            examples-build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            examples-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector

      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Compile all examples using the bash script arduino-test-compile.sh
        env:
          # Passing parameters to the script by setting the appropriate ENV_* variables.
          ENV_ARDUINO_BOARD_FQBN: ${{ matrix.arduino-boards-fqbn }}
          ENV_PLATFORM_DEFAULT_URL: ${{ env.PLATFORM_DEFAULT_URL }}
          ENV_PLATFORM_URL: ${{ matrix.platform-url }}
          ENV_REQUIRED_LIBRARIES: ${{ env.REQUIRED_LIBRARIES }}
          ENV_EXAMPLES_EXCLUDE: ${{ matrix.examples-exclude }}
          ENV_EXAMPLES_BUILD_PROPERTIES: ${{ toJson(matrix.examples-build-properties) }}
          ENV_SKETCH_NAMES: ${{ matrix.sketch-names }}
          ENV_SKETCH_NAMES_FILE_START: examples/ # Not really required here, but serves as an usage example.
        run: |
          wget --quiet https://raw.githubusercontent.com/ArminJo/arduino-test-compile/master/arduino-test-compile.sh
          chmod +x arduino-test-compile.sh
          ./arduino-test-compile.sh
```

## Using custom library
Add an extra step `Checkout custom library` for loading custom library.
Take care that the path parameter matches the pattern `*Custom*`.
```yaml
...
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Checkout custom library
        uses: actions/checkout@v2
        with:
          repository: ArminJo/ATtinySerialOut
          ref: master
          path: CustomLibrary # must contain string "Custom"

      - name: Checkout second custom library # This name must be different from the one above
        uses: actions/checkout@v2
        with:
          repository: ArminJo/Arduino-Utils
          ref: master
          path: SecondCustomLibrary # This path must be different from the one above but must also contain string "Custom"
...
```

## Single [program](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master/src) using `sketch-names` parameter
```yaml
name: TestCompile
on: push
jobs:
  build:
    name: Test compiling examples for UNO
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@master
        with:
          sketch-names: SimpleTouchScreenDSO.cpp
          required-libraries: BlueDisplay
```

Samples for using action in workflow:
- The simple example from above. LightweightServo [![Build Status](https://github.com/ArminJo/LightweightServo/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/LightweightServo/blob/master/.github/workflows/LibraryBuild.yml)
- One sketch, one library. Simple-DSO [![Build Status](https://github.com/ArminJo/Arduino-Simple-DSO/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-Simple-DSO/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, only arduino:avr boards. Talkie [![Build Status](https://github.com/ArminJo/Talkie/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/Talkie/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, 2 boards. Arduino-FrequencyDetector [![Build Status](https://github.com/ArminJo/Arduino-FrequencyDetector/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/Arduino-FrequencyDetector/blob/master/.github/workflows/LibraryBuildWithAction.yml)

Samples for using `arduino-test-compile.sh script` instead of `ArminJo/arduino-test-compile@v2` action:
- One sketch, one board, multiple options. RobotCar [![Build Status](https://github.com/ArminJo/Arduino-RobotCar/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-RobotCar/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, multiple boards. ServoEasing [![Build Status](https://github.com/ArminJo/ServoEasing/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/ServoEasing/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, multiple boards. NeoPatterns [![Build Status](https://github.com/ArminJo/NeoPatterns/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/NeoPatterns/blob/master/.github/workflows/LibraryBuild.yml)

# Revision History
### Version v2.5.0
- Build result files (and build temporaryfiles) are now stored in the build source directory by internally using cli parameter *--build-path*.
- Fixed skipped compile of examples, if one *.ino file is present in the repository root.
- `examples-build-properties` now used also for **c and S* extra_flags.
- Added `save-generated-files` parameter.

### Version v2.4.1
- Only search for files when using `sketch-names`.

### Version v2.4.0
- Added parameter `sketch-names-find-start` to compile multiple libraries.
- Added parameter `platform-default-url` to ease compiling for multiple boards of the same architecture.
- Suppress warnings for install python and pip for ESP32.
- Added debug parameters

### Version v2.3.0
- Support for custom libraries.

### Version v2.2.0
- Using ubuntu:18.04 for Docker container, since ubuntu:latest can not fetch python for ESP32 anymore.
- `CPP_EXTRA_FLAGS` are now resetted.

### Version v2.1.0 -> as of 30.4.2020 internally upgraded to content of v2.2.0, because of ESP32 compile bug
- Added missing newline after print of "Install libraries $REQUIRED_LIBRARIES".
- Added semantic for example name `All` in `examples-build-properties`.

### Version v2.0.0 -> as of 30.4.2020 internally upgraded to content of v2.2.0, because of ESP32 compile bug
- Changed `required-libraries` from **space** to **comma** separated list.
- Renamed parameter `sketch-name` to `sketch-names` to enable comma separated list.
- Accept comma separated list for `examples-exclude`.
- Updated documentation. 

### Version v1.1.0 -> as of 30.4.2020 internally upgraded to content of v2.2.0, because of ESP32 compile bug
- Renamed parameter `libraries` to `required-libraries`.
- Renamed script.
- Script instead of action can be used in steps.
- Added parameter `arduino-platform` to enable specifying the version of the required platform.

### Version v1.0.0
- Initial tested version.

## Requests for modifications / extensions
Please write me a PM including your motivation/problem if you need a modification or an extension.

#### If you find this action useful, please give it a star.
