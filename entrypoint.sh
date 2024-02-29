#!/bin/bash
set -e

## copy default files if config folder is empty
if [ -z "$(ls -A /config_files)" ]; then
    USER_ID=${UID:0}
    GROUP_ID=${GID:0}
    echo "Init config files with permissions: UID $USER_ID, GID $GROUP_ID"
    cp /src/motley_cue/etc/motley_cue.conf /config_files
    cp /src/motley_cue/etc/feudal_adapter.conf /config_files
    cp /src/motley_cue/etc/gunicorn.conf.py /config_files
    chown -R $USER_ID:$GROUP_ID /config_files
fi

exec "$@"
