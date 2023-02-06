<div align = center>

# arduino-test-compile [action](https://github.com/marketplace/actions/test-compile-for-arduino)
This action does a test-compile of one or more [Arduino programs](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master) in a repository for different boards<br/>
each with different compile parameters.<br/>
It can be used e.g. to test-compile all examples contained in an [Arduino library repository](https://github.com/ArminJo/NeoPatterns/tree/master/examples).

[![Badge License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)
 &nbsp; &nbsp; 
 [![Badge Version](https://img.shields.io/github/v/release/ArminJo/arduino-test-compile?include_prereleases&color=yellow&logo=DocuSign&logoColor=white)](https://github.com/ArminJo/arduino-test-compile/releases/latest)
 &nbsp; &nbsp; 
[![Badge Commits since latest](https://img.shields.io/github/commits-since/ArminJo/arduino-test-compile/latest?color=yellow)](https://github.com/ArminJo/arduino-test-compile/commits/master)
 &nbsp; &nbsp; 
[![Badge Build Status Action](https://github.com/ArminJo/Github-Actions/workflows/LibraryBuildWithAction/badge.svg)](https://github.com/ArminJo/Github-Actions/actions)
 &nbsp; &nbsp; 
[![Badge Build Status Script](https://github.com/ArminJo/Github-Actions/workflows/LibraryBuildWithScript/badge.svg)](https://github.com/ArminJo/Github-Actions/actions)
 &nbsp; &nbsp; 
![Badge Hit Counter](https://visitor-badge.laobi.icu/badge?page_id=ArminJo_arduino-test-compile)
<br/>
<br/>
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)

</div>
<br/>

### If you see errors like `Node.js 12 actions are deprecated` update your checkout action from `actions/checkout@v2` to `actions/checkout@v3` or `actions/checkout@master`.

The action is a "composite run steps" action which uses the [arduino-cli program](https://github.com/arduino/arduino-cli) for compiling. All the work like loading libraries, installing board definitions and setting parameters is orchestrated by the [arduino-test-compile.sh](arduino-test-compile.sh) bash script.

In case of a compile error the **complete compile output** is logged in the *Compile all examples...* step, otherwise only a **green check** is printed. Examples can be found [here](https://github.com/ArminJo/ServoEasing/actions).

If you want to test compile a sketch, **it is not required that the sketch resides in a directory with the same name (as Arduino IDE requires it) or has the extension .ino**. Internally the file is renamed to be .ino and the appropriate directory is created on the fly at `/home/runner/<sketch-name>` for test-compiling. See [parameter `sketch-names`](sketch-names).

Since version 0.11.0 of arduino-cli, the **generated files** (.bin, .hex, .elf, .eep etc.) can be found in the build/<FQBN> subfolder of the example directory `$GITHUB_WORKSPACE/src/<example_name>`  or in `$HOME/<sketch-name>` for files not residing in a directory with the same name.<br/>

# Hints
- If you require a **custom library for your build**, add an extra step for [loading a custom library](#using-custom-library).<br/>
Be aware to use the `path:` parameter for checkout, otherwise checkout will overwrite the last checkout content.<br/>
Take care that the path parameter matches the pattern `*Custom*` like [here](https://github.com/ArminJo/Arduino-Simple-DSO/blob/master/.github/workflows/TestCompile.yml#L24). You do not need to put the "Custom" library in the required-libraries list.

- If you have problems with you workflow file, you find additional information in the output if you set the [flags](#debug-compile-and-debug-install) `debug-compile` and / or `debug-install` to `true`.<br/>

- If actions / workflow for your repository is not enabled, select `Allow all actions` it in your repositorys *Settings -> Actions -> General* menu.

# Inputs
See [action.yml](https://github.com/ArminJo/arduino-test-compile/blob/master/action.yml) for comprehensive list of parameters.

### `arduino-board-fqbn`
The fully qualified board name to use for compiling with arduino-cli. You may add a suffix behind the fqbn with `|` to specify one board for e.g. different compile options like `arduino:avr:uno|trace`.<br/>
Default is `arduino:avr:uno`.<br/>

```yaml
arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
```

**For 3rd party boards**, you must also specify the Boards Manager URL `platform-default-url:` or `platform-url:`.

### `platform-default-url`
Default value to take, if `platform-url` is not specified for a 3rd party board. Useful, if you want to test compile for different boards types of one architecture.<br/>
Default is `""`.<br/>

```yaml
platform-default-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

### `platform-url`
Required for 3rd party boards, if `platform-default-url` is not specified or applicable. If you need, you may specify more than one URL as a comma separated list (without enclosing it in double quotes) like `http://drazzy.com/package_drazzy.com_index.json,https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json`.<br/>
Default is `""`.<br/>

```yaml
  platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

[Unofficial list of 3. party URL's](https://github.com/arduino/Arduino/wiki/Unofficial-list-of-3rd-party-boards-support-urls)

Some [sample URL's](https://github.com/arduino/Arduino/wiki/Unofficial-list-of-3rd-party-boards-support-urls) are:
- http://drazzy.com/package_drazzy.com_index.json - for ATTiny boards
- https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json - for Digistump AVR boards. Up to 20% smaller code
- https://files.pololu.com/arduino/package_pololu_index.json - for Pololu boards, esp. ATmega328PB boards<br/><br/>
- https://arduino.esp8266.com/stable/package_esp8266com_index.json - for ESP8266 based boards
- https://dl.espressif.com/dl/package_esp32_index.json - for ESP32 based boards<br/><br/>
- https://github.com/stm32duino/BoardManagerFiles/raw/master/package_stmicroelectronics_index.json - STMicroelectronics:stm32 for STM32 boards
- http://dan.drown.org/stm32duino/package_STM32duino_index.json - stmduino: for STM32 boards
- https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json - for Sparkfun boards
- https://raw.githubusercontent.com/sparkfun/Arduino_Apollo3/master/package_sparkfun_apollo3_index.json - for Sparkfun Apollo3 boards
- https://sandeepmistry.github.io/arduino-nRF5/package_nRF5_boards_index.json - for nRF528x based boards like Nano 33 BLE<br/><br/>
- https://downloads.arduino.cc/packages/package_index.json - Built in URL for default Arduino boards, not required to specify
- https://mcudude.github.io/MegaCore/package_MCUdude_MegaCore_index.json - ATmega64, ATmega128, ATmega640, ATmega1280, ATmega1281, ATmega2560, ATmega2561 etc.
- https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json - ATmega328, ATmega168, ATmega88, ATmega48 and ATmega8. Two extra IO pins if using the internal oscillator

### `arduino-platform`
Comma separated list of platform specifiers with optional version to specify multiple platforms for your board or a fixed version like `arduino:avr@1.8.2`.<br/>
The suffix `@latest` is always removed from specified platform to enable usage of platform versions in a matrix.<br/>
In general, use it only if you require another specifier than the one derived from the 2 first elements of the arduino-board-fqbn e.g. **esp8266:esp8266**:huzzah:eesz=4M3M,xtal=80, esp32:esp32:featheresp32:FlashFreq=80 -> **esp8266:esp8266**. Do not forget to specify the related URL's, if it is not the arduino URL, which is built in.<br/>
Useful in the case you require a dedicated version of a core or two cores as for MegaCore, which requires the compiler from the Arduino core.<br/>
It is also useful if you install the core manually, but require e.g. tools from another core.<br/>
Default is `""`.<br/>

```yaml
arduino-platform: arduino:avr,SparkFun:avr@1.1.13
platform-url: https://raw.githubusercontent.com/sparkfun/Arduino_Boards/master/IDE_Board_Manager/package_sparkfun_index.json # Arduino URL is not required here

- arduino-boards-fqbn: MegaCore:avr:128:bootloader=no_bootloader,eeprom=keep,BOD=2v7,LTO=Os,clock=8MHz_internal
  platform-url: https://mcudude.github.io/MegaCore/package_MCUdude_MegaCore_index.json
  arduino-platform: MegaCore:avr,arduino:avr # gcc is taken from arduino:avr

```

### `required-libraries`
Comma separated list of arduino library dependencies to install. You may add a version number like `@1.3.4`.<br/>
Only libraries [available in the Arduino library manager](https://www.arduinolibraries.info/) can be installed this way.<br/>
If you want to use other or custom libraries, you must put all the library files into the sketch directory or add an extra step as in [this example](#using-custom-library).<br/>
Be careful, some library names can contain spaces, e.g. `LiquidCrystal I2C` even if they are defined in *library.properties* with underscores like: `name=LiquidCrystal_I2C`.<br/>
Default is `""`.<br/>

```yaml
required-libraries: Servo,Adafruit NeoPixel@1.3.4,${{ env.REQUIRED_LIBRARIES }},${{ matrix.required-libraries }}
```

A **list of correct Arduino library names** can be found [here](https://www.arduinolibraries.info/).


### `sketches-exclude`
Sketches to be **excluded from build**. Comma or space separated list of complete sketch / example names to exclude in build. Comment is only allowed at the end of the list<br/>

```yaml
  # 1.TinyWireM not usable; 2. incompatible I2C Hardware for Wire.h; 3. SoftPwm is not required and not working
  sketches-exclude:
    WiiClassicJoystick
    BasicUsage,DigisparkOLED,DigiUSB2LCD
    SoftPwm13Pins,TinySoftPwmDemo
    DigisparkUSBDemo ArduinoNunchukDemo DigisparkJoystickDemo # Nunchuck library: incompatible I2C Hardware, the original library uses TinyWireM library

```

### `build-properties`
Build parameter like `-DDEBUG` for each example specified or for all examples which have no dedicated specification, if example name is `All`. I.e. if an example specific parameter is specified, the value for All is ignored for this example.<br/>
The content is passed to the arduino-cli commandline in 3 parameters:<br/>
`--build-property compiler.[cpp,c,S].extra_flags="${GCC_EXTRA_FLAGS}"`

In the `include:` section you may specify:

```yaml
include:
...
  build-properties:
    SymmetricEasing:
      -DDISABLE_COMPLEX_FUNCTIONS
      -DDEBUG
    AsymmetricEasing:
      -DTRACE
    Simple: -DPRINT_FOR_SERIAL_PLOTTER
    PCA9685_ExpanderFor32Servos: -DTRACE -DENABLE_MICROS_AS_DEGREE_PARAMETER
...
  build-properties:
    Simple:
      -DPRINT_FOR_SERIAL_PLOTTER -DDEBUG
    All:
      -DDEBUG
...
```

and reference it in the `with:` section by: 

```yaml
with:
  build-properties: ${{ toJson(matrix.build-properties) }}
```

If you want to specify it directly in the `with:` section it must be:

```yaml
with:
  build-properties: '{ "WhistleSwitch": "-DDEBUG -DFREQUENCY_RANGE_LOW", "SimpleFrequencyDetector": "-DINFO", "All": "-DDEBUG" }'
```

### `extra-arduino-cli-args`
This string is passed verbatim without additional quoting to the arduino-cli compile commandline as last argument before the filename.
See https://arduino.github.io/arduino-cli/commands/arduino-cli_compile/ for compile parameters.<br/>
E.g. if you specify `extra-arduino-cli-args: "--warnings default"`, this overwrites the default setting of `--warnings all` for compile, which may be especially useful for ESP32 source compilation.<br/>
Be aware, that you cannot add to `--build-property compiler.[cpp,c,S].extra_flags`, if you already specified `build-properties`, they will be overwritten by your content. See https://github.com/arduino/arduino-cli/pull/1044.

This example tells arduino-cli to do the lolin32 build for what the Arduino IDE calls *Tools > Partition Scheme > No OTA (Large APP)*, what can also be specified with `arduino-boards-fqbn: esp32:esp32:lolin32:PartitionScheme=no_ota`.

```yaml
strategy:
  matrix:
    arduino-board-fqbn:
    - esp32:esp32:lolin32
    include:
      - arduino-boards-fqbn: esp32:esp32:lolin32
        extra-arduino-cli-args: "--warnings default --build-property build.partitions=no_ota --build-property upload.maximum_size=2097152"
    ...
steps:
- name: Arduino build
  uses: ArminJo/arduino-test-compile@master
  with:
    ...
    arduino-board-fqbn: ${{ matrix.arduino-board-fqbn }}
    extra-arduino-cli-args: ${{ matrix.extra-arduino-cli-args }}
```

### `extra-arduino-lib-install-args`
This string is passed verbatim without double quotes to the arduino-cli lib install commandline as last argument before the library names. It can be used e.g. to suppress dependency resolving for libraries by using `--no-deps` as argument string.

```yaml
steps:
- name: Arduino build
  uses: ArminJo/arduino-test-compile@v3
  with:
    ...
    arduino-board-fqbn: ${{ matrix.arduino-board-fqbn }}
    extra-arduino-lib-install-args: "--no-deps"
```

### `cli-version`
The version of `arduino-cli` to use.<br/>
Default is `latest`.<br/>

```yaml
cli-version: 0.9.0 # The current one (3/2020)
```

### `sketch-names`
Comma separated list of patterns or filenames (without path) of the sketch(es) to test compile. Useful if the sketch is a *.cpp or *.c file or only one sketch in the repository should be compiled. If first character is a `*` like in "*.ino" the list must be enclosed in double quotes!<br/>
The **sketch names to compile are searched in the whole repository** by the command `find . -name "$SKETCH_NAME"` with `.` as the root of the repository, so you do not need to specify the full path.<br/>
If you specify `sketch-names-find-start` then the find command is changed to `find ${PWD}/${SKETCH_NAMES_FIND_START} -name "$SKETCH_NAME"`.<br/>
Sketches do not need to be in an example directory. This enables **[plain programs](https://github.com/ArminJo/Arduino-Simple-DSO/tree/master) to be test compiled**.<br/>
Since Arduino requires a sketch to end with .ino and to reside in a directory with the same name as the sketch, if required, the **renaming and directory creation is done internally** to fulfill the requirements of the Arduino IDE.<br/>
Default is `*.ino`.<br/>

```yaml
sketch-names: "*.ino,SimpleTouchScreenDSO.cpp"
```

### `sketch-names-find-start`
The **start directory to look for the sketch-names** to test compile. Can be a path like `digistump-avr/libraries/*/examples/`. Must be a path **relative to the root of the repository**. Used [here](https://github.com/ArminJo/DigistumpArduino/blob/master/.github/workflows/TestCompile.yml#L90) to compile all library examples of the board package.
Default is `.` (root of repository).<br/>

```yaml
sketch-names-find-start: digistump-avr/libraries/*/examples/C*/
```

### `set-build-path`
If set to true, the build directory (arduino-cli paramer --build-path) is set to `$GITHUB_WORKSPACE/src/<example_name>/build/`  or to `$HOME/<sketch-name>/build/` for files not residing in a directory with the same name.<br/>
This is useful, if you need to access the result files of the Arduino build in later workflow steps.
Default is `false`.<br/>

```yaml
set-build-path: true
```

### `debug-compile` and `debug-install`
If you have problems with you workflow file, try to set this flags to `true`.<br/>
Default is `false`.<br/>

# Workflow examples
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
      uses: actions/checkout@v3
    - name: Compile all examples
      uses: ArminJo/arduino-test-compile@v3
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
      uses: actions/checkout@v3

    - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v3
      with:
        arduino-board-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
        platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
        required-libraries: Servo,Adafruit NeoPixel
        sketches-exclude: WhistleSwitch 50Hz
        build-properties: '{ "WhistleSwitch": "-DDEBUG -DFREQUENCY_RANGE_LOW", "SimpleFrequencyDetector": "-DINFO" }'
```

## One board with 2x2 compile parameter matrix
```yaml
name: LibraryBuild with parameter matrix
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
    name: ${{ matrix.arduino-boards-fqbn }} ${{ matrix.log-options }} ${{ matrix.other-options }}
    runs-on: ubuntu-latest
    env:
      REQUIRED_LIBRARIES: Servo,Adafruit NeoPixel
    strategy:
      matrix:
        arduino-boards-fqbn:
          - arduino:avr:uno

        log-options: [-DDEBUG, -DINFO]

        other-options: [-DTEST, -DDUMMY]

      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v3
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-url: ${{ matrix.platform-url }}
          required-libraries: ${{ env.REQUIRED_LIBRARIES }}
          build-properties: '{ "All": "${{ matrix.log-options }} ${{ matrix.other-options }}" }'

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
            build-properties:
              WhistleSwitch:
                -DDEBUG
                -DFREQUENCY_RANGE_LOW
              SimpleFrequencyDetector:
                -DINFO

          - arduino-boards-fqbn: arduino:avr:uno|All-DEBUG # UNO board with -DDEBUG for all examples
            sketches-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            build-properties:
              All:
                -DDEBUG

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            sketches-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            platform-url: https://arduino.esp8266.com/stable/package_esp8266com_index.json
            sketches-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector

          - arduino-boards-fqbn: esp32:esp32:featheresp32:FlashFreq=80
            platform-url: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
            required-libraries: ESP32 ESP32S2 AnalogWrite

      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@v3
        with:
          arduino-board-fqbn: ${{ matrix.arduino-boards-fqbn }}
          platform-default-url: ${{ env.PLATFORM_DEFAULT_URL }}
          platform-url: ${{ matrix.platform-url }}
          required-libraries: ${{ env.REQUIRED_LIBRARIES }},${{ matrix.required-libraries }}
          sketch-names: ${{ matrix.sketch-names }}
          sketches-exclude: ${{ matrix.sketches-exclude }}
          build-properties: ${{ toJson(matrix.build-properties) }}
```

## Using custom library
Add an extra step `Checkout custom library` for loading custom library. **You must use the `path:` parameter, otherwise checkout overwrites the last checkout content.**<br/>
Take care that the path parameter matches the pattern `*Custom*` like [here](https://github.com/ArminJo/Arduino-Simple-DSO/blob/master/.github/workflows/TestCompile.yml#L24).<br/>
You do not need to put the custom libraries, you loaded manually, in the `required-libraries` list, since they are already loaded now!<br/>
But if you use this library as **substitute for an Arduino library** take care to remove the substituted Arduino linrary in your `required-libraries` list.
```yaml
...
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Checkout custom library
        uses: actions/checkout@v3
        with:
          repository: ArminJo/ATtinySerialOut
          ref: master
          path: CustomLibrary # must contain string "Custom"
          # No need to put "Custom" library in the required-libraries list

      - name: Checkout second custom library # This name must be different from the one above
        uses: actions/checkout@v3
        with:
          repository: ArminJo/Arduino-BlueDisplay
          ref: master
          path: CustomLibrary_BlueDisplay # This path must be different from the one above but must also contain string "Custom"
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
        uses: actions/checkout@v3

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@master
        with:
          sketch-names: SimpleTouchScreenDSO.cpp
          required-libraries: BlueDisplay
```


## Testing a core, which is not yet released using `arduino-platform` parameter like [here](https://github.com/ArminJo/DigistumpArduino/blob/master/.github/workflows/TestCompile.yml)
```yaml
name: TestCompile
on: push
jobs:
  build:
    name: Test compiling examples for Digispark
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arduino-boards-fqbn:
          - digistump:avr:digispark-tiny   # ATtiny85 board @16.5 MHz
          - digistump:avr:MHETtiny88 # Chinese MH-Tiny ATTiny88
        include:
          - arduino-boards-fqbn: digistump:avr:MHETtiny88  # ATtiny88 China clone board @16 MHz
            # 1.TinyWireM not usable; 2. incompatible I2C Hardware for Wire.h; 3. SoftPwm is not required and not working
            sketches-exclude:
              WiiClassicJoystick
              BasicUsage,DigisparkOLED,DigiUSB2LCD
              SoftPwm13Pins,TinySoftPwmDemo
              DigisparkUSBDemo ArduinoNunchukDemo DigisparkJoystickDemo # Nunchuck library: incompatible I2C Hardware, the original library uses TinyWireM library
      # Do not cancel all jobs / architectures if one job fails
      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Use this repo as Arduino core
        run: |
          mkdir --parents $HOME/.arduino15/packages/digistump/hardware/avr/0.0.7 # dummy release number
          cp --recursive $GITHUB_WORKSPACE/digistump-avr/* $HOME/.arduino15/packages/digistump/hardware/avr/0.0.7/

      - name: Compile all examples
        uses: ArminJo/arduino-test-compile@master
        with:
          arduino-board-fqbn: digistump:avr:digispark-tiny
          arduino-platform: digistump:avr,arduino:avr # we require the C compiler from it. See dependencies of package_digistump_index.json
          sketches-exclude: ${{ matrix.sketches-exclude }}
          sketch-names: "*.ino"
          sketch-names-find-start: digistump-avr/libraries/*/examples/
```

## Multiple boards with parameter using the **script directly**
**This is not longer required since version v3.0.0.**

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
            build-properties:
              WhistleSwitch:
                -DDEBUG
                -DFREQUENCY_RANGE_LOW
              SimpleFrequencyDetector:
                -DINFO

          - arduino-boards-fqbn: arduino:avr:uno|All-DEBUG # UNO board with -DDEBUG for all examples
            sketches-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            build-properties:
              All:
                -DDEBUG

          - arduino-boards-fqbn: arduino:avr:uno|trace # UNO board with different build properties
            sketches-exclude: 50Hz # Comma separated list of (unique substrings of) example names to exclude in build
            build-properties:
              WhistleSwitch:
                -DDEBUG
                -DTRACE

          - arduino-boards-fqbn: esp8266:esp8266:huzzah:eesz=4M3M,xtal=80
            sketches-exclude: WhistleSwitch,50Hz,SimpleFrequencyDetector

      fail-fast: false

    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Compile all examples using the bash script arduino-test-compile.sh
        env:
          # Passing parameters to the script by setting the appropriate ENV_* variables.
          ENV_ARDUINO_BOARD_FQBN: ${{ matrix.arduino-boards-fqbn }}
          ENV_PLATFORM_DEFAULT_URL: ${{ env.PLATFORM_DEFAULT_URL }}
          ENV_PLATFORM_URL: ${{ matrix.platform-url }}
          ENV_REQUIRED_LIBRARIES: ${{ env.REQUIRED_LIBRARIES }}
          ENV_SKETCHES_EXCLUDE: ${{ matrix.sketches-exclude }}
          ENV_BUILD_PROPERTIES: ${{ toJson(matrix.build-properties) }}
          ENV_SKETCH_NAMES: ${{ matrix.sketch-names }}
          ENV_SKETCH_NAMES_FIND_START: examples/ # Not really required here, but serves as an usage example.
        run: |
          wget --quiet https://raw.githubusercontent.com/ArminJo/arduino-test-compile/master/arduino-test-compile.sh
          chmod +x arduino-test-compile.sh
          ./arduino-test-compile.sh
```

Samples for using action in workflow:
- The simple example from above. LightweightServo [![Build Status](https://github.com/ArminJo/LightweightServo/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/LightweightServo/blob/master/.github/workflows/LibraryBuild.yml)
- One sketch, one library. Simple-DSO [![Build Status](https://github.com/ArminJo/Arduino-Simple-DSO/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-Simple-DSO/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, only arduino:avr boards. Talkie [![Build Status](https://github.com/ArminJo/Talkie/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/Talkie/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, 2 boards, script used. Arduino-FrequencyDetector [![Build Status](https://github.com/ArminJo/Arduino-FrequencyDetector/workflows/LibraryBuildWithScript/badge.svg)](https://github.com/ArminJo/Arduino-FrequencyDetector/blob/master/.github/workflows/LibraryBuildWithAction.yml)

- One sketch, one board, multiple options. RobotCar [![Build Status](https://github.com/ArminJo/Arduino-RobotCar/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/Arduino-RobotCar/blob/master/.github/workflows/TestCompile.yml)
- Arduino library, multiple boards. ServoEasing [![Build Status](https://github.com/ArminJo/ServoEasing/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/ServoEasing/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino library, multiple boards. NeoPatterns [![Build Status](https://github.com/ArminJo/NeoPatterns/workflows/LibraryBuild/badge.svg)](https://github.com/ArminJo/NeoPatterns/blob/master/.github/workflows/LibraryBuild.yml)
- Arduino core. DigistumpArduino [![TestCompile](https://github.com/ArminJo/DigistumpArduino/workflows/TestCompile/badge.svg)](https://github.com/ArminJo/DigistumpArduino/actions)

# Revision History
### Version v3.3.0
- The suffix `@latest` is always removed from specified `arduino-platform`.
- Early exit on platform install error as suggested by *tobozo*.

### Version v3.2.1
- Merged #26, which fixes filename problems, especially with filenames with multiple dots.
- Extended debug output.

### Version v3.2.0
- Added parameter `extra-arduino-lib-install-args`.

### Version v3.1.0
- Suppress check for platform-url if core was manually installed before.
- Changed deprecated arduino-cli parameter build-properties to build-property. The build-properties parameter of the action is unaffected.
- Added parameter `extra-arduino-cli-args`.

### Version v3.0.0
- Converted from a "Docker action" to a much faster "composite run steps" action.
- Removed deprecated parameter `examples-exclude` and `examples-build-properties` from action definition.

### Version v2.6.0
- Renamed `examples-exclude` to `sketches-exclude`. Old name is still valid.
- Renamed `examples-build-properties` to `build-properties`. Old name is still valid.
- Fixed print cli version bug.

### Version v2.5.0 -> Due to a Github failure/outage on 13.07.2020 the old 2.5.0 version from 10.07.20 (and 2.5.1 from 12.07.20 ) was removed.
- Fixed skipped compile of examples, if one *.ino file is present in the repository root.
- `examples-build-properties` now used also for **c and S* extra_flags.
- Improved error and debug flags handling.
- Added `set-build-path`.

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
- `CPP_EXTRA_FLAGS` are now reseted.

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
