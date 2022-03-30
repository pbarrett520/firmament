# Installation

## Windows

### 0: Obtain the source code
For programmers, this is a trivial step. Simply clone this repository.

For non-programmers, this may be more difficult to understand. We use the tool `git` to check out the source code and track changes. If you want to use `git`, you'll need to do the following:
- Download the [Git installer](https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe)
- Run the Git installer, making sure to check any box that asks whether to add Git to the path. Adding a program to the path allows it to be found when typed into a command line.
- Reboot, to ensure your path is updated with Git.
- Make a GitHub account
- Open a command prompt (e.g. by typing `cmd.exe` into the Windows search panel). Change directories to the place where you'd like to install the game.
- Run `git clone https://github.com/spaderthomas/firmament.git`

Congratulations. You now have the source code. Follow the rest of the guide to build it.

### 1: Install Visual Studio 2019

Install the [community edition of Visual Studio 2019](https://visualstudio.microsoft.com/downloads/). When the installer prompts you to choose what components to install, make sure that "Desktop development with C++" is checked.

## 2: Install Python

If you don't have Python, install the latest stable release from [here](https://www.python.org/downloads/windows/) by selecting the latest version, scrolling to the bottom, and downloading + running the 64-bit installer.

In the installer:
- Make sure the option to install Pip is selected
- Make sure "Add Python to environment variables" is selected

## 3: Reboot

Adding things to your path can be finicky -- it's easiest to reboot to make sure that any command prompts you open have the updated path.

## 4: Install tdbuild

This project uses my simple build tool, [tdbuild](https://github.com/spaderthomas/tdbuild). You need to install tdbuild using Python's package manager, Pip. It's as easy as `pip install tdbuild` from any command prompt. For any non-programmers: Press the Windows key, then type in `cmd.exe`. Run the entry called `Command Prompt`. From here, type in the pip command.

## 5: Build

To build this project, you need to open a Visual Studio command prompt. This command prompt has the C++ linker, compiler, etc. already inserted into the path. If you try to build in a regular command prompt, you will not be able to find the build tools, and it will not work.

To open a VS command prompt, press the Windows key and search for "x64 Native Tools Command Prompt for VS 2019". Selecting it should open a prompt. You'll use this prompt to build.

Change directories into the root of the project. For non-programmers, run something like `cd C:/Path/To/Where/Project/Is`. Once you are in this directory, run `tdbuild setup`. This will generate a few machine-specific files you need to build the project. Then, run `tdbuild` to build the project. You'll get some messages from the build tool. Once it builds, run `tdbuild run` to run the engine.
