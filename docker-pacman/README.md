Building Pacman packages
===

These scripts are intended only for [ijacquez](https://github.com/ijacquez), and
could be moved to private repository soon.

1. In the `docker-pacman` directory, build the image.

       docker build --tag yaul-packages \
           --build-arg SMB_SERVER=... \   # SMB server name or IP where the Pacman repo is shared
           --build-arg SMB_NAME=... \     # SMB share name
           .

2. Once the image is built, update `yaul-git` package by calling
   `package-build-yaul.sh`.

       docker run -it --rm --privileged -e REPO_OS=${REPO_OS} yaul-packages:latest ./package-build-$TYPE.sh

   | `$TYPE`          | `REPO_OS=linux` | `REPO_OS=mingw-w64` | Description                       |
   |------------------|-----------------|---------------------|-----------------------------------|
   | `yaul`           | Y               | Y                   | Build pre-compiled Yaul libraries |
   | `yaul-examples`  | Y               | Y                   | Bundle uncompiled Yaul examples   |
   | `yaul-emulators` | N               | Y                   | Bundle pre-compiled emulators     |
