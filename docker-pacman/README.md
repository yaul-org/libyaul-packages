Pacman docker
===

## Building Pacman packages

These scripts are intended only for [ijacquez](https://github.com/ijacquez), and
could be moved to private repository soon.

1. Build the image.

       docker build \
           --rm \
           --tag ijacquez/yaul-packages \
           .

2. Once the image is built, run one of the scripts

       ./update-yaul.sh
       ./update-yaul-examples.sh
       ./update-yaul-emulators.sh
       ./update-yaul-tool-chain.sh
       ./update-ssshell.sh

## Known issues

1. Package `libftdi` has a [bug](https://bugs.archlinux.org/task/69115) in its
   `pkg-config` file.

2. MinGW can't build its own `yaul-tool-chain` package, as crosstool-NG requires
   a case-sensitive filesystem.

   I haven't tested this, but possibly enabling specific directories to be case
   sensitive might resolve this issue.

       fsutil.exe file setCaseSensitiveInfo 'C:\msys64\path\to\work' enable

3. Linux doesn't have `yaul-emulator-yabause` available.

4. MinGW doesn't have `yaul-emulator-kronos` available.
