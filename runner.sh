#!/bin/bash
set -e

/etc/init.d/nscd start &
/etc/init.d/nslcd start &
gunicorn motley_cue.api:api \
    -k "uvicorn.workers.UvicornWorker" \
    --bind unix:/run/motley_cue/motley-cue.sock \
    --log-level info \
    --config /config_files/gunicorn.conf.py \
    --access-logfile "-" --error-logfile "-" &
# /etc/init.d/rsyslog restart &
/usr/sbin/sshd -D -e
wait -n
