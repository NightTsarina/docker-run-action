#!/usr/bin/env bash

set -x

find_envvars() {
  local IFS='='
  printenv --null | \
  while read -d '' key val; do
    case "$key" in
      ACTIONS_* | GITHUB_* | RUNNER_* | HOME | CI)
        echo "$key"
        ;;
      *)
        ;;
    esac
  done
}

notice_cmd() {
  echo "echo '::notice::$@'"
}

notice() {
  echo "::notice::$@"
}

# Ensure lower-case image name.
INPUT_IMAGE="$(echo "$INPUT_IMAGE" | tr '[:upper:]' '[:lower:]')"

# Prepare entry-point script.
TMPDIR=$(mktemp -d)
USER_SCRIPT="${TMPDIR}"/user_script

notice_cmd "Starting user script..." > "${USER_SCRIPT}"
echo "$INPUT_RUN" >> "${USER_SCRIPT}"
notice_cmd "Finished user script." >> "${USER_SCRIPT}"

ARGS=()
ARGS+=(--rm)
ARGS+=(--interactive)
ARGS+=(-v /var/run/docker.sock:/var/run/docker.sock)
ARGS+=(-v "${RUNNER_WORKSPACE}:${GITHUB_WORKSPACE}")
ARGS+=(-w "${GITHUB_WORKSPACE}")

if [ ! -z "$INPUT_DOCKER_NETWORK" ]; then
    ARGS+=(--network "$INPUT_DOCKER_NETWORK")
fi

# Re-export environment.
for var in $(find_envvars); do
  ARGS+=(-e "$var")
done

notice Launching Docker..
exec docker run "${ARGS[@]}" $INPUT_OPTIONS "$INPUT_IMAGE" ${INPUT_SHELL:-sh}
    < "${USER_SCRIPT}"
