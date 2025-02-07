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
    gdb \
    cmake-curses-gui \
    curl \
    ca-certificates

# ----- CMake setup ----- #
ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="3.22.2"

# Optionally install the cmake for vcpkg
COPY ./.devcontainer/reinstall-cmake.sh /tmp/

RUN ls -l /tmp/

RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

# [Optional] Uncomment this section to install additional vcpkg ports.
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# ----- User setup ----- #
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

# Change HOME environment variable
ENV USER=${USER}
ENV HOME=/home/${USER}

# Set up environment
# COPY ./.devcontainer/.config/update_bashrc.sh /sbin/update_bashrc.sh
# RUN sudo chmod +x /sbin/update_bashrc.sh ; sudo chown ${USER} /sbin/update_bashrc.sh \
#     && echo 'echo "source '${PWDR}'/devel/setup.bash" >> ~/.bashrc' >> /sbin/update_bashrc.sh \
#     && cat /sbin/update_bashrc.sh \
#     && sync ; /bin/bash -c /sbin/update_bashrc.sh ; sudo rm /sbin/update_bashrc.sh

# Change entrypoint to source ~/.bashrc and start in ~
COPY ./.devcontainer/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh ; chown ${USER} /entrypoint.sh \
    && echo "cd "${PWDR} >> /entrypoint.sh \
    && echo 'exec bash -i -c $@' >> /entrypoint.sh

# Clean image
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Choose to run as user
USER ${USER}

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
# CMD ["bash"]