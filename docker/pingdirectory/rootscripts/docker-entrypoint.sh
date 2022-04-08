#!/bin/bash -eux

start() {
    set -ex
    echo "Starting DS"
    CMD_RUN=
    if [[ "${CMD}" = "start" ]]; then
      CMD_RUN="exec tini -v -- "
    fi
    ${CMD_RUN}./bin/start-ds --nodetach
}

init() {
    echo "Initializing with profile: ${INIT_INSTANCE_PROFILE}"
    if [ -d "/opt/ping/directory/config" ]; then
        ./default-scripts/${INIT_INSTANCE_PROFILE}/init.sh
    else
        rm -rf instance.loc
        ./default-scripts/${INIT_INSTANCE_PROFILE}/setup.sh
    fi
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