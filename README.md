# ldap_dev

Docker compose for running [SSH with OIDC token based authentication](https://github.com/EOSC-synergy/ssh-oidc).

The image contains:
- ssh service with PAM-based authentication & ChallengeResponseAuthentication enabled
- [motley_cue](https://github.com/dianagudu/motley_cue) service for user provisioning, authorisation and name resolution
- [PAM](https://git.man.poznan.pl/stash/scm/pracelab/pam.git) module for token based authentication

## Usage

### Prerequisites
- docker
- docker-compose

### Run

First pull the git submodules so that you have the code for `motley_cue` and `feudalAdapterLdf` in the `src/` folder.

Next, you'll need to set the following environment variables:

- `CONFIG_FOLDER`: location of config files for the `motley_cue` service (if it doesn't exist, it will be created and populated with the default configs)
- `UID`: user id to be used when creating the `CONFIG_FOLDER`
- `GID`: group id to be used when creating the `CONFIG_FOLDER`

The file `.env` contains some default values for these variables, change them as you wish.

Then run:
```
docker-compose up
```

This will expose the motley_cue service on [http://localhost:8080](http://localhost:8080) and the SSH service on port 1022.

You can configure the authorisation in `$CONFIG_FOLDER/motley_cue.conf`. Restart the `motley_cue_pam_ssh` container for the changes to take effect.

### Usage

Requirements:
- [oidc-agent](https://github.com/indigo-dc/oidc-agent)
- [mccli](https://github.com/dianagudu/mccli)

[Install](https://indigo-dc.gitbook.io/oidc-agent/installation/install) `oidc-agent` and [configure](https://indigo-dc.gitbook.io/oidc-agent/user/oidc-gen) an account for your preferred OP. The image currently supports [Helmholtz AAI dev](https://login-dev.helmholtz.de/oauth2) and [EGI](https://aai.egi.eu/oidc) OPs.

Install `mccli` simply by:
```
pip install mccli
```

To automatically create a user and ssh into your container using a configured oidc-agent account:
```
export OIDC_AGENT_ACCOUNT=<configured oidc-agent account shortname>
mccli ssh localhost -p 1022
```