# Docker_ws - ROS2_Franka

General purpose docker workspaces to use ROS2 and Franka framework and developing inside a container. This is an extension of [docker_ros_nvidia](https://github.com/ddebenedittis/docker_ros_nvidia) from [Davide De Benedittis](https://github.com/ddebenedittis) meant to the ones that wants to use vscode for developing inside a container.
The ROS part is very similar to the forked repository, so refer to it. Differently, here each different system has a branch that you can directly clone and use.

## Overview
Workspaces to build images with different systems with GUI support (e.g. Gazebo and RViz).

The `build.bash` and the `run.bash` files are used to automatically build and run the image.
`attach.bash` can be used to connect to the same container created with devcontainer.
To connect to the container created with `run.bash` you can use directly 
``` docker exec -it <container_name> bash```

This repository is intended to be used as a base for other projects that require ROS, and GUI support in Docker. Providing also the infrastructure for developing inside the container (devcontainer extension).

The overall idea is to clone the repository and add to .gitignore what you will insert. In this way you can keep track of the modification of the docker structure, while maintaining separate repositories for your works.

If you find this useful, you can cite [this repository](https://github.com/GiorgioSimonini/docker_ws) and/or [me](https://github.com/GiorgioSimonini) in your work.


## Preliminaries
Install [Docker Community Edition](https://docs.docker.com/engine/install/ubuntu/) (ex Docker Engine).
You can follow the installation method through `apt`.
Note that it makes you verify the installation by running `sudo docker run hello-world`.
It is better to avoid running this command with `sudo` and instead follow the post installation steps first and then run the command without `sudo`.

Follow with the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) for Linux.
This will allow you to run Docker without `sudo`.

## Usage
The docker base image and the ROS version can be changed by modifying the `BASE_IMAGE` and the `BASE_TAG` in the `dockerfile`.

You can simply open the folder in vscode and use the devcontainer extension to create the container and attach to it.

Otherwise you can build the docker image:
```shell
./docker/build.bash
```

and run the container with:
```shell
./docker/run.bash
```

The workspace directory should be the folder containing `run.bash` and `build.bash`. It is mounted in the Docker container on startup.

Build the workspace inside the Docker container with colcon or catkin to avoid permission problems. The workspace's `setup.bash` is automatically sourced when the container is opened; thus it will fail the first time the container is run.

Take a look at https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ before modifying the Dockerfile according to your needs.

To use VS Code with Docker, you have two method:
- you can use the Dev Containers extension to attach VS Code to a running container. For having autocomplete, linting, etc. take a look at https://github.com/athackst/vscode_ros2_workspace and in particular to `c_cpp_properties.json` and `settings.json` in `.vscode`.
- you can also compile the image from vscode. If the container is opened from vscode, the container will be persistent and you can install what you want without loosing it on code closing. However, the changes will be lost when you recreate the image, so pay attention.

## Troubleshooting

## Authors

[Giorgio Simonini](https://github.com/GiorgioSimonini)


## Acknowledgments

- [Davide De Benedittis](https://github.com/ddebenedittis)
- [Baptiste Busch](https://medium.com/@baptiste.busch/creating-a-ros-or-ros2-workspace-in-docker-part-1-912529c87708): creation of a ROS workspace in Docker

