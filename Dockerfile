FROM debian:bullseye as motley_cue_pam_ssh_dev

##### install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ssh \
    python3 \
    python3-pip \
    libcurl4 \
    curl \
    gpg \
    libnss-ldapd \
    libpam-ldapd \
    rsyslog
RUN echo deb [signed-by=/etc/apt/trusted.gpg.d/kitrepo-archive.gpg] https://repo.data.kit.edu/debian/bullseye ./ \
    >> /etc/apt/sources.list
RUN curl repo.data.kit.edu/repo-data-kit-edu-key.gpg \
    | gpg --dearmor \
    > /etc/apt/trusted.gpg.d/kitrepo-archive.gpg
RUN apt-get update && apt-get install -y \
    pam-ssh-oidc-autoconfig=0.2.0-8 \
    && rm -rf /var/lib/apt/lists/*

##### ldap config


##### ssh config
RUN mkdir /run/sshd
RUN echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication yes" > /etc/ssh/sshd_config.d/oidc.conf \
    && echo "KbdInteractiveAuthentication yes" >> /etc/ssh/sshd_config.d/oidc.conf

##### pam config
RUN sed -i "s/localhost/mc_endpoint/g" /etc/pam.d/pam-ssh-oidc-config.ini

##### motley-cue config
RUN mkdir /etc/motley_cue /var/log/motley_cue /run/motley_cue \
    && ln -s /config_files/motley_cue.conf /etc/motley_cue/motley_cue.conf \
    && ln -s /config_files/feudal_adapter.conf /etc/motley_cue/feudal_adapter.conf
ENV FEUDAL_ADAPTER_CONFIG=/etc/motley_cue/feudal_adapter.conf

#### install dev requirements
COPY requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt
ENV PYTHONPATH /src/motley_cue:/src/feudalAdapterLdf:${PYTHONPATH}
ENV PYTHONUNBUFFERED 1

#### LDAP client config
COPY nslcd.conf /etc/nslcd.conf
COPY nsswitch.conf /etc/nsswitch.conf
RUN chown nslcd:nslcd /etc/nslcd.conf && chmod 0600 /etc/nslcd.conf

##### expose needed ports
EXPOSE 22

##### init cmd and entrypoint
COPY ./runner.sh /srv/runner.sh
COPY ./entrypoint.sh /srv/entrypoint.sh
RUN chmod +x /srv/runner.sh /srv/entrypoint.sh

ENTRYPOINT [ "/srv/entrypoint.sh" ]
CMD ["/srv/runner.sh"]
