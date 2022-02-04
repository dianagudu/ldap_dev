#!/bin/bash

docker-compose down
docker volume rm ldap-dev_openldap_data ldap-dev_motley_cue_sock
docker-compose up
