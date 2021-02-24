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

       docker run -it --rm --privileged yaul-packages:latest \
           bash -c "bash /home/builder/package-build-yaul.sh"
