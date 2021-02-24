FROM archlinux:latest

MAINTAINER Israel Jacquez <mrkotfw@gmail.com>

ARG GITHUB_USERNAME
ARG SMB_SERVER
ARG SMB_NAME

ENV HOME /home/builder

ENV GIT_USERNAME="ijacquez"
ENV GIT_NAME="Israel Jacquez"
ENV GIT_EMAIL="mrkotfw@gmail.com"

ENV REPO_ROOT_PATH="${HOME}/SMB"

RUN if [ -z "$SMB_SERVER" ]; then echo  "\x1b[1;31mEnvironment variable SMB_SERVER must be specified. Exiting.\x1b[m\n"; exit 1; fi
RUN if [ -z "$SMB_NAME" ];   then echo  "\x1b[1;31mEnvironment variable SMB_NAME must be specified. Exiting.\x1b[m\n"; exit 1; fi

RUN useradd -m builder

WORKDIR $HOME

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/${patched_glibc}" && \
    bsdtar -C / -xvf "${patched_glibc}"

RUN /usr/bin/pacman -Syy --noconfirm && \
    /usr/bin/pacman -S --noconfirm \
        base-devel \
        cifs-utils \
        git \
        s3cmd \
        openssh

# Allow builder to run stuff as root (to install dependencies):
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/builder

USER builder

COPY --chown=builder:builder .s3cfg $HOME/
COPY --chown=builder:builder .smbcredentials $HOME/
COPY --chown=builder:builder id_rsa $HOME/.ssh/id_rsa.github.com

COPY --chown=builder:builder s3sync.sh $HOME/
COPY --chown=builder:builder package-build-yaul.sh $HOME/

RUN /bin/mkdir -p ${REPO_ROOT_PATH}

RUN /bin/mkdir -p ${HOME}/.ssh
RUN echo $'Host github.com\n\
  User '$GIT_USERNAME$'\n\
  IdentityFile '$HOME$'/.ssh/id_rsa.github.com\n\
  StrictHostKeyChecking no\n'\
>>"${HOME}/.ssh/config"

RUN echo $'[user]\n\
        name = '$GIT_NAME$'\n\
        email = '$GIT_EMAIL >>"${HOME}/.gitconfig"

RUN sudo -E /bin/sh -c 'echo "//${SMB_SERVER}/${SMB_NAME} ${REPO_ROOT_PATH} cifs users,credentials=$HOME/.smbcredentials,iocharset=utf8,uid=builder,gid=builder 0 0"\
>> /etc/fstab'

RUN sudo -E /bin/sh -c 'printf -- "\n\
[yaul-linux]\n\
SigLevel = Optional TrustAll\n\
Server = http://packages.yaul.org/linux/x86_64\n\
\n\
[yaul-mingw-w64]\n\
SigLevel = Optional TrustAll\n\
Server = http://packages.yaul.org/mingw-w64/x86_64\n" >> /etc/pacman.conf'

CMD ["/bin/bash"]
