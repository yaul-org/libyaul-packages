Pacman docker
===

## Building Pacman packages

These scripts are intended only for [ijacquez](https://github.com/ijacquez), and
could be moved to private repository soon.

1. In the `docker-pacman` directory, build the image.

        docker build \
            --rm \
            --tag yaul-packages \
            --build-arg SMB_SERVER=... \ # SMB server name or IP where the Pacman repo is shared
            --build-arg SMB_NAME=... \   # SMB share name
            .

2. Once the image is built, run the image in a container.

        docker run -it --rm --privileged -e REPO_OS=${REPO_OS} yaul-packages:latest ./package-build-$TYPE.sh

   Specify a `$TYPE` and `$REPO_OS` from the table below:

   | `$TYPE`           | `REPO_OS=linux` | `REPO_OS=mingw-w64` | Description                       |
   |-------------------|-----------------|---------------------|-----------------------------------|
   | `yaul-tool-chain` | N               | N                   | Build tool-chain                  |
   | `yaul`            | Y               | Y                   | Build pre-compiled Yaul libraries |
   | `yaul-examples`   | Y               | Y                   | Bundle uncompiled Yaul examples   |
   | `yaul-emulators`  | N               | Y                   | Bundle pre-compiled emulators     |

## Known issues

1. Arch Linux image requires a workaround with glibc in the `Dockerfile`.

2. Package `libftdi` has a [bug](https://bugs.archlinux.org/task/69115) in its
   `pkg-config` file.

3. MinGW can't build its own `yaul-tool-chain` package, as crosstool-NG requires
   a case-sensitive filesystem.

   I haven't tested this, but possibly enabling specific directories to be case
   sensitive might resolve this issue.

        fsutil.exe file setCaseSensitiveInfo 'C:\msys64\path\to\work' enable

4. Linux doesn't have `yaul-emulator-yabause` available.
