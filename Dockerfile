FROM lancachenet/monolithic:latest
LABEL maintainer="Josh.5 <jsunnex@gmail.com>"


# This Dockerfile is designed to simply pull together the docker-compose
# lancache project into a single image.
# It is not supposed to over complicate things or re-invent the wheel.
# As such, it will be based on their monolithic docker image and will install
# the various DNS and sniproxy components on top.
#
# In order to simply maintenance of this docker image in comparison to the
# upstream sniproxy and DNS components, some parts such as the ENV variables
# may be repeated. This is fine as it is not a production docker image, but
# is designed for personal home use only.
#



# lancache-monolithic env variables
ENV GENERICCACHE_VERSION=2 \
    CACHE_MODE=monolithic \
    WEBUSER=www-data \
    CACHE_MEM_SIZE=500m \
    CACHE_DISK_SIZE=1000000m \
    CACHE_MAX_AGE=3560d \
    CACHE_SLICE_SIZE=1m \
    UPSTREAM_DNS="8.8.8.8" \
    BEAT_TIME=1h \
    LOGFILE_RETENTION=3560 \
    CACHE_DOMAINS_REPO="https://github.com/uklans/cache-domains.git" \
    CACHE_DOMAINS_BRANCH=master \
    NGINX_WORKER_PROCESSES=auto


# lancache-dns env variables
ENV STEAMCACHE_DNS_VERSION=1 \
    ENABLE_DNSSEC_VALIDATION=false \
    LANCACHE_DNSDOMAIN=cache.lancache.net \
    CACHE_DOMAINS_REPO=https://github.com/uklans/cache-domains.git \
    CACHE_DOMAINS_BRANCH=master \
    UPSTREAM_DNS=8.8.8.8


# Install dependencies
RUN \
    apt-get update \
    && apt-get install -y \
        jq \
        curl \
        git \
    && \
    echo "**** Clone cache-domains ****" \
        && git clone --depth=1 --no-single-branch https://github.com/uklans/cache-domains /opt/cache-domains \
    && \
    echo "**** Cleanup files ****" \
        && rm -rf /tmp/* \
        && rm -rf /var/lib/apt/lists/*


# Install dns and bind 
RUN \
    echo "**** Install dns and bind ****" \
    && apt-get update \
    && apt-get install -y \
        bind9 \
        dnsutils \
    && \
    echo "**** Install lancache-dns configs ****" \
        && git clone --depth=1 https://github.com/lancachenet/lancache-dns /tmp/lancache-dns \
        && cp -rfv /tmp/lancache-dns/overlay/*  / \
        && mkdir -p /var/cache/bind /var/log/named \
	    && chown bind:bind \
            /var/cache/bind \
            /var/log/named \
    && \
    echo "**** Set permissions ****" \
        && chmod 755 /scripts/* \
    && \
    echo "**** Cleanup setup files ****" \
        && rm -rf /tmp/* \
        && rm -rf /var/lib/apt/lists/*


# Copy in any local config files
COPY overlay/ /


# Set the DNS_BIND_IP to the local host because all the services are now running together...
ENV DNS_BIND_IP=127.0.0.1


# Set ports to expose
EXPOSE 80
EXPOSE 53/udp
EXPOSE 443


# Set volumes that are required
VOLUME ["/var/log", "/data/cache", "/var/www"]


WORKDIR /scripts
