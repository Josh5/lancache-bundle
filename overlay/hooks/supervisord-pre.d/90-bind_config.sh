#!/bin/bash
set -e


echo "Configuring Bind..."


mkdir -p \
    /var/cache/bind \
    /var/log/named

chown -R bind:bind \
    /var/cache/bind \
    /var/log/named

