#!/bin/bash -eux

checkVolume() {
    if [ -d /var/ping/directory/data/db ]; then
        rm -rf {db,config}
        ln -s /var/ping/directory/data/{db,config} .
    fi
}

start() {
    set -ex

    checkVolume
    
    echo "Starting DS"
    CMD_RUN=
    if [[ "${CMD}" = "start" ]]; then
      CMD_RUN="exec tini -v -- "
    fi
    ${CMD_RUN}./bin/start-server --nodetach
}


init() {
    echo "Initializing with profile: ${INIT_INSTANCE_PROFILE}"
    if [ "$(ls -A /var/ping/directory/data/db)" ]; then
        ./default-scripts/${INIT_INSTANCE_PROFILE}/init.sh
    else
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