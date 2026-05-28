FROM ubuntu:latest

LABEL org.opencontainers.image.title="rayyounghong/dev-ubuntu" \
      org.opencontainers.image.source="https://github.com/rayyh/dotfiles"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    SHELL=/bin/bash

# Install sudo, curl, git as root before anything else
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo curl git && \
    rm -rf /var/lib/apt/lists/*

# Rename the pre-existing ubuntu user (UID/GID 1000) to ray
RUN usermod -l ray -s /bin/bash ubuntu && \
    usermod -d /home/ray -m ray && \
    groupmod -n ray ubuntu && \
    echo "ray ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ray && \
    echo "Defaults:ray !requiretty" >> /etc/sudoers.d/ray && \
    chmod 0440 /etc/sudoers.d/ray

ENV HOME=/home/ray
WORKDIR $HOME

# Copy dotfiles
COPY --chown=ray:ray . $HOME/dotfiles

# Run bootstrap as root (EUID=0 → script sets SUDO="" so sudo is never called)
# Set HOME to ray's directory so tools like nvm/cargo install there, not /root
RUN bash -c 'echo "y" | HOME=/home/ray S_EMACS=1 bash /home/ray/dotfiles/bootstrap/bootstrap-ubuntu.sh' && \
    chown -R ray:ray /home/ray

# Install dotfiles as ray
USER ray
RUN bash $HOME/dotfiles/install.sh

CMD ["bash", "--login"]
