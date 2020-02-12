FROM josh5/base-alpine:3.10
LABEL maintainer="Josh.5 <jsunnex@gmail.com>"


################################
### Config:
###
# set version for s6 overlay
ARG S6_INIT_SCRIPTS_VERSION="v0.12"
ARG S6_INIT_PACKAGES="nginx"

ENV CACHE_MEM_SIZE 500m \
    CACHE_DISK_SIZE 500000m \
    CACHE_MAX_AGE 3560d \
    STEAMCACHE_DNS_VERSION=1 \
    ENABLE_DNSSEC_VALIDATION=false \
    LANCACHE_DNSDOMAIN=cache.lancache.net \
    CACHE_DOMAINS_REPO=https://github.com/uklans/cache-domains.git \
    CACHE_DOMAINS_BRANCH=master \
    UPSTREAM_DNS=8.8.8.8


### Build
RUN \
    echo "**** Install base packages ****" \
        && apk add --no-cache \
            nginx \
            bind \
            sniproxy \
            git \
            bash \
            jq \
    && \
    echo "**** Clone cache-domains ****" \
        && git clone --depth=1 https://github.com/uklans/cache-domains/ /opt/cache-domains \
    && \
    echo "**** Install init process ****" \
        && curl -L "https://github.com/josh5/s6-init/archive/${S6_INIT_SCRIPTS_VERSION}.tar.gz" -o /tmp/s6-init.tar.gz \
        && tar xfz /tmp/s6-init.tar.gz -C /tmp \
        && cd /tmp/s6-init-* \
        && ./install \
    && \
    echo "**** Cleanup setup files ****" \
        && rm -rf /tmp/*


### Environment variables
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8


### Add local files
COPY root/ /


EXPOSE 80
EXPOSE 53/udp
EXPOSE 443
