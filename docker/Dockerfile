FROM debian:stable

# Prevent bash to ask for user input which may break the building process
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, and some essential packages
RUN apt-get update && apt-get install --no-install-recommends -qqy \
    nano \
    bash-completion \
    build-essential \
    git \
    sudo \
    wget \
    gdb

ARG MYUID=1000
ARG MYGID=1000
ARG USER=docker
ARG PWDR=/

RUN OLD_USER=$(awk -v uid="$MYUID" -F ':' '$3==uid {print $1}' /etc/passwd) \
    && if [ -z "${OLD_USER}" ]; then \
        # There is no existing UID equal to MYUID.
        # Create the same user as the host itself. (By default Docker creates the container as root, which is not recommended.)
        addgroup --gid ${MYGID} ${USER} \
        && adduser --gecos "ROS User" --disabled-password --uid ${MYUID} --gid ${MYGID} ${USER} \
        && usermod -a -G dialout ${USER} \
        && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
        && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget ; \
    else \
        usermod -l ${USER} ${OLD_USER} \
        && sudo usermod -d /home/${USER} -m ${USER} \
        && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
        && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget ; \
    fi

# Choose to run as user
ENV USER=${USER}
USER ${USER}

# Change HOME environment variable
ENV HOME=/home/${USER}

# Set up environment
# COPY ./docker/.config/update_bashrc.sh /sbin/update_bashrc.sh
# RUN sudo chmod +x /sbin/update_bashrc.sh ; sudo chown ${USER} /sbin/update_bashrc.sh \
#     && echo 'echo "source '${PWDR}'/devel/setup.bash" >> ~/.bashrc' >> /sbin/update_bashrc.sh \
#     && cat /sbin/update_bashrc.sh \
#     && sync ; /bin/bash -c /sbin/update_bashrc.sh ; sudo rm /sbin/update_bashrc.sh

# Change entrypoint to source ~/.bashrc and start in ~
COPY ./docker/.config/entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh ; sudo chown ${USER} /entrypoint.sh \
    && echo "cd "${PWDR} >> /entrypoint.sh \
    && echo 'exec bash -i -c $@' >> /entrypoint.sh \
    && cat /entrypoint.sh

# Clean image
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]