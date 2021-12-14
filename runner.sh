#!/bin/bash
set -e

gunicorn motley_cue.api:api \
    -k "uvicorn.workers.UvicornWorker" \
    --bind unix:/run/motley_cue/motley-cue.sock \
    --log-level info \
    --config /config_files/gunicorn.conf.py \
    --access-logfile "-" --error-logfile "-" &
/etc/init.d/nscd restart &
/etc/init.d/nslcd restart &
/usr/sbin/sshd -D -e
wait -n
