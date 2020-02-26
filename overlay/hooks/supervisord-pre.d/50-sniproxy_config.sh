#!/bin/sh
set -e

echo "Setting Upstream DNS to ${UPSTREAM_DNS}"
sed -i "s/UPSTREAM_DNS/${UPSTREAM_DNS}/"    /etc/sniproxy.conf
