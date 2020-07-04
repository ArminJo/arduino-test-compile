const path = require('path');
const core = require('@actions/core');
const exec = require('@actions/exec');

// This is a minimal bit of javascript that collects the inputs and
// passes them to the main shell script.

async function run() {
  try {
    const args = [
      core.getInput('cli-version'),
      core.getInput('sketch-names'),
      core.getInput('sketch-names-find-start'),
      core.getInput('arduino-board-fqbn'),
      core.getInput('arduino-platform'),
      core.getInput('platform-default-url'),
      core.getInput('platform-url'),
      core.getInput('required-libraries'),
      core.getInput('examples-exclude'),
      core.getInput('examples-build-properties'),
      core.getInput('debug-compile'),
      core.getInput('debug-install')
    ];

    // Use the current filename to derive the path to the script
    const dirname = path.dirname(__filename);
    const script = path.join(dirname, 'arduino-test-compile.sh');

    // And execute the script
    await exec.exec(script, args);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run()
