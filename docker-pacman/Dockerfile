FROM archlinux:latest

MAINTAINER Israel Jacquez <mrkotfw@gmail.com>

ENV HOME /home/builder

ENV REPO_ROOT_PATH="${HOME}/s3"

RUN useradd -m builder

WORKDIR $HOME

RUN /usr/bin/pacman -Syyu --noconfirm && \
    /usr/bin/pacman -Syy --noconfirm && \
    /usr/bin/pacman -S --noconfirm \
        base-devel \
        cifs-utils \
        git \
        s3cmd \
        openssh \
        # Required for yaul-tool-chain-git
        community/mingw-w64-gcc \
        # Required for yaul-emulator-kronos-git
        qt5-base \
        # Required for yaul-emulator-kronos-git
        glut && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

USER builder

# Allow builder to run stuff as root (to install dependencies):
RUN sudo -E /bin/sh -c 'printf -- "\n\
[yaul-linux]\n\
SigLevel = Optional TrustAll\n\
Server = http://packages.yaul.org/linux/x86_64\n\
\n\
[yaul-mingw-w64]\n\
SigLevel = Optional TrustAll\n\
Server = http://packages.yaul.org/mingw-w64/x86_64\n" >> /etc/pacman.conf'

CMD ["/bin/bash"]
