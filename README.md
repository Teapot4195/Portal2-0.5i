# Portal2+0.5i

A Fanmade Sequel to the original portal series

## Building a copy for yourself

### Prerequisites

In order to build a copy of this game you will need a few prerequisites:
- a copy of the godot source from [this fork](https://github.com/Teapot4195/godot)
- a C++ compiler
- SCons build tool
- Git

### Production builds

When building production builds, the only change that needs to be made to the commands are that you need to add `production=yes` to the command line.
In some cases, adding `lto=full` may be helpful too, just remember this is GCC only (apparently).

### Building a copy of godot for use with this project

cd into the godot source, preferably this source is outside of the project root, however it will be fine under the `godot` folder inside the project root.

You can now build a copy of godot, use this [documentation](https://docs.godotengine.org/en/latest/contributing/development/compiling/index.html) from the godot docs to help you.

### Building a copy of the c++ Static Libraries

cd into the project root, then `git submodule update --init` to collect the git submodules.

The rest of this build assumes latest godot from fork is on path as godot.

First, generate an `extension_api.json` file by calling `godot --dump-extension-api extension_api.json` in project root.

Then youcan build a copy of the godot-cpp libraries using `scons platform=<platform> -j<jobs> custom_api_file=<PATH_TO_FILE> bits=64` just remember to replace `<platform>` with `windows`, `linux`, or `macos` depending on os. `<jobs>` with the amount of cores you would like to use, and `<PATH_TO_FILE>` with the path to the `extension_api.json` file we generated earlier.

### Buidling a copy of the c++ GDExtension for this project

cd into the project root if you are not here already, then use `scons platform=<platform> -j<jobs>` to build, just remember to replace `<platform>` with `windows`, `linux`, or `macos` depending on os. `<jobs>` with the number of cores you would like to use.

### END

This is the end of your C++ build journey, the rest of this project can be built using tools from the godot editor, you're on your own (for now: TODO).
