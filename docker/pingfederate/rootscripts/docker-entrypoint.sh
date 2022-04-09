#!/bin/bash -eux

./default-scripts/init.sh

start() {
    set -ex
    echo "Starting ping federate"
    CMD_RUN=
    if [[ "${CMD}" = "start" ]]; then
      CMD_RUN="exec tini -v -- "
    fi
    ${CMD_RUN}./bin/run.sh
}

init() {
    ./default-scripts/${INIT_INSTANCE_TYPE}/init.sh
}

CMD="${1:-run}"
echo "Command is $CMD"

case "$CMD" in
devspace)
    start
    ;;
start)
    start
    ;;
init)
    init
    ;;
*)
    exec "$@"
esac