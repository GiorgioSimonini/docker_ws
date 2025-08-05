#!/bin/bash

export MYUID=$(id -u)
export MYGID=$(id -g)
echo "MYUID=$(id -u)" > .devcontainer/.env
echo "MYGID=$(id -g)" >> .devcontainer/.env

docker compose -f .devcontainer/docker-compose.yml build