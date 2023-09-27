# Portal2+0.5i

## Preparing for the build

Get a few prerequisites:
- a copy of godot from (this fork)[https://github.com/Teapot4195/godot]
- a C++ compiler
- SCons build tool
- Git

After getting all these prerequisites, cd into the project root, then `git submodule update --init` to collect the git submodules.

The rest of this build assumes latest godot from fork is on path as godot.

First, generate an `extension_api.json` file by calling `godot --dump-extension-api extension_api.json` in project root.

Then youcan build a copy of the godot-cpp libraries using `scons platform=<platform> -j<jobs> custom_api_file=<PATH_TO_FILE> bits=64` just remember to replace `<platform>` with `windows`, `linux`, or `macos` depending on os. `<jobs>` with the amount of cores you would like to use, and `<PATH_TO_FILE>` with the path to the `extension_api.json` file we generated earlier.

Now that you have a copy of the cpp static libraries: TODO
