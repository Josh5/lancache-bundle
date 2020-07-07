#!/bin/bash
set -e


echo "Configuring Nginx..."


# Ensure directory exists
mkdir -p /var/log/nginx


# Change nginx settings to point to the stdout log locations
sed -i -e "s|access_log .*$|access_log /var/log/nginx/access.log  cachelog;|"  /etc/nginx/sites-available/10_generic.conf;
sed -i -e "s|error_log .*$|error_log /var/log/nginx/error.log;|"  /etc/nginx/sites-available/10_generic.conf;


# Ensure nginx log files are not symlinks
if [[ -h /var/log/nginx/access.log ]]; then
    rm -f /var/log/nginx/access.log;
    touch /var/log/nginx/access.log;
fi
if [[ -h /var/log/nginx/error.log ]]; then
    rm -f /var/log/nginx/error.log;
    touch /var/log/nginx/error.log;
fi

# Set permissions of nginx log files
chown -Rf ${WEBUSER}:adm /var/log/nginx


# TODO: Make this work at some point... I think it is nicer to point logs to stdout 
# Set default access logs to stdout and stderr
# if [ "${LOG_TO_FILES}" = "false" ]; then
# 
#     # Set nginx access log to stdout
#     if [[ ! -h /var/log/nginx/access.log ]]; then
#         rm -f /var/log/nginx/access.log;
#         ln -s /dev/stdout /var/log/nginx/access.log;
#     fi
# 
#     # Set nginx access log to stderr
#     if [[ ! -h /var/log/nginx/error.log ]]; then
#         rm -f /var/log/nginx/error.log;
#         ln -s /dev/stderr /var/log/nginx/error.log;
#     fi
# 
#     # Set permissions of nginx log files
#     chown -R ${WEBUSER}:adm /var/log/nginx/*
# 
#     # Remove logrotate
#     rm -f /etc/logrotate.d/nginx;
# 
# fi
