# ldap_dev

Development environment for the LDAP backend in FEUDAL. It contains the full environment for testing [SSH with OIDC token based authentication](https://github.com/EOSC-synergy/ssh-oidc).

The docker-compose setup contains:
- LDAP server for managing users
- ssh service with PAM-based authentication & ChallengeResponseAuthentication enabled
- [motley_cue](https://github.com/dianagudu/motley_cue) service for user provisioning, authorisation and name resolution
- [PAM](https://git.man.poznan.pl/stash/scm/pracelab/pam.git) module for token based authentication

## Usage

### Prerequisites
- docker
- docker-compose

### Run

First pull the git submodules so that you have the code for `motley_cue` and `feudalAdapterLdf` in the `src/` folder:

```
git submodule init
git submodule update
```

Next, you'll need to set the following environment variables:

- `CONFIG_FOLDER`: location of config files for the `motley_cue` service (if it doesn't exist, it will be created and populated with the default configs)
- `UID`: user id to be used when creating the `CONFIG_FOLDER`
- `GID`: group id to be used when creating the `CONFIG_FOLDER`

The file `.env` already contains some sane default values for these variables, but you can change them as you wish.

Then run:
```
docker-compose up
```

This will expose the motley_cue service on [http://localhost:8080](http://localhost:8080) and the SSH service on port 1022.

You can configure the authorisation in `$CONFIG_FOLDER/motley_cue.conf`. Restart the `motley_cue_pam_ssh_dev` container for the changes to take effect.


### LDAP configuration

You can control the feudalAdapter configuration for the LDAP backend in [config_files/feudal_adapter.conf](config_files/feudal_adapter.conf#L207). There are two modes currently supported:

- read_only: there is read only access to the LDAP, therefore the local accounts
    need to already be created in the LDAP and mapped to the federated accounts through a user 
    attribute containing the OIDC unique id (a masked 'sub@iss' string); the name of this attribute
    can be configured via `attribute_oidc_uid`.
- pre_created: the local accounts already exist in the LDAP, but they are not mapped;
    the feudal adapter should have write access to the LDAP to modify entries in
    order to add the mapping to the federated OIDC account.

You can modify the user database in the LDAP in [ldifs/test_users.ldif](ldifs/test_users.ldif).


### Usage

Requirements:
- [oidc-agent](https://github.com/indigo-dc/oidc-agent)
- [mccli](https://github.com/dianagudu/mccli)

[Install](https://indigo-dc.gitbook.io/oidc-agent/installation/install) `oidc-agent` and [configure](https://indigo-dc.gitbook.io/oidc-agent/user/oidc-gen) an account for your preferred OP. The image currently supports [Helmholtz AAI dev](https://login-dev.helmholtz.de/oauth2) and [EGI](https://aai.egi.eu/oidc) OPs, among others (see [config_files/motley_cue.conf](config_files/motley_cue.conf)).

Install `mccli` simply by:
```
pip install mccli
```

To ssh into your container using a configured oidc-agent account named `egi`:
```
mccli ssh localhost -p 1022 --oidc egi
```

### Known issues

When you update the LDAP user database, you need to remove the docker volume to make sure the old database is not cached:

```
docker-compose down
docker volume rm ldap_dev_openldap_data
docker-compose up -d
```