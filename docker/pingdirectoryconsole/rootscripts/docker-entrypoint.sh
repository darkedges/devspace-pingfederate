#!/bin/bash -eux

CMD="${1:-run}"
echo "Command is $CMD"

case "$CMD" in
*)
    exec "$@"
esac
