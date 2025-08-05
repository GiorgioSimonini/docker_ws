# Change ROS version in docker-compose.yml, not here!
ARG BASE_IMAGE=debian
ARG BASE_TAG=stable

FROM ${BASE_IMAGE}:${BASE_TAG}

# Prevent bash to ask for user input which may break the building process
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, and some essential packages
RUN apt update && apt install --no-install-recommends -qqy \
    bash-completion \
    build-essential \
    git \
    sudo \
    wget \
    gdb \
    nano \
    cmake-curses-gui \
    iputils-ping \
    curl \
    openssh-client \
    python3-pip \
    ca-certificates \
    cmake \
    libprotobuf-dev \
    protobuf-compiler

# # ----- CMake setup ----- #
# ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="3.22.2"

# # Optionally install the cmake for vcpkg
# COPY ./.devcontainer/reinstall-cmake.sh /tmp/

# RUN ls -l /tmp/

# RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
#         chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
#     fi \
#     && rm -f /tmp/reinstall-cmake.sh

# [Optional] Uncomment this section to install additional vcpkg ports.
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Uncomment this section to install additional packages.
# RUN apt update && export DEBIAN_FRONTEND=noninteractive \
#     && apt -y install --no-install-recommends <your-package-list-here>

# ----- User setup ----- #
ARG MYUID=1000
ARG MYGID=1000
ARG USER=docker
ARG PWDR=/
ENV WORKDIR=${PWDR}

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

# # ----- Real-Time capabilities ----- #    
# RUN groupadd realtime \
# && if id "$USER" &>/dev/null; then \
#   usermod -a -G realtime "$USER"; \
# else \
#   groupadd -g $MYGID $USER && \
#   useradd -m -u $MYUID -g $MYGID -G realtime -s /bin/bash $USER; \
# fi \
# && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# # Insert real-time limits at the end of the file
# RUN sed -i '/# End of file/i \
# @realtime soft rtprio 99\n\
# @realtime soft priority 99\n\
# @realtime soft memlock 1048576\n\
# @realtime hard rtprio 99\n\
# @realtime hard priority 99\n\
# @realtime hard memlock 1048576\n' /etc/security/limits.conf
# # ----- end Real-Time ----- #

# Choose to run as user
ENV USER=${USER}
USER ${USER}

# Change HOME environment variable
ENV HOME=/home/${USER}

RUN echo "" >> $HOME/.bashrc \
    && echo "## DOCKER_WS ##" >> $HOME/.bashrc \
    && echo "export PS1='[\[\033[1;34m\]DOCKER\[\033[0m\]]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> $HOME/.bashrc \
    && echo "export RCUTILS_COLORIZED_OUTPUT=1" >> $HOME/.bashrc \
    && echo "export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity} {time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'" >> $HOME/.bashrc \
    && echo "touch ${PWDR}/.devcontainer/commandhistory/.bash_history" >> $HOME/.bashrc \
    && echo "chown -R $USER ${PWDR}/.devcontainer/commandhistory" >> $HOME/.bashrc

# Change entrypoint to source ~/.bashrc and start in ~
COPY ./entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh ; sudo chown ${USER} /entrypoint.sh \
    && echo "cd "${PWDR} >> /entrypoint.sh \
    && echo 'exec bash -i -c $@' >> /entrypoint.sh

# Clean image
RUN sudo apt clean && sudo rm -rf /var/lib/apt/lists/*


# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]