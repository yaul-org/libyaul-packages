FROM archlinux:latest

MAINTAINER Israel Jacquez <mrkotfw@gmail.com>

ENV HOME /home/builder

RUN useradd -m builder

WORKDIR $HOME

RUN /usr/bin/pacman -Syu --noconfirm && \
    /usr/bin/pacman -S --noconfirm base-devel git s3cmd openssh

RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

# Allow builder to run stuff as root (to install dependencies):
RUN /bin/sh -c 'printf -- "\n\
[yaul]\n\
SigLevel = Optional TrustAll\n\
Server = http://packages.yaul.org/pacman/x86_64\n" >> /etc/pacman.conf'

USER builder

CMD ["/bin/bash"]
