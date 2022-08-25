#!/usr/bin/env bash

if [ ! -z "$INPUT_USERNAME" ]; then
    echo "$INPUT_PASSWORD" | \
        docker login "$INPUT_REGISTRY" -u "$INPUT_USERNAME" --password-stdin
fi

if [ ! -z "$INPUT_DOCKER_NETWORK" ]; then
    INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi

INPUT_OPTIONS="$INPUT_OPTIONS -v /var/run/docker.sock:/var/run/docker.sock"
INPUT_IMAGE="$(echo "$INPUT_IMAGE" | tr '[:upper:]' '[:lower:]')"

exec docker run $INPUT_OPTIONS --entrypoint="$INPUT_SHELL" "$INPUT_IMAGE" \
    -c "${INPUT_RUN//$'\n'/;}"
