############################################################
# Dockerfile to build QuickBox Dashboard container images
# Based on Ubuntu/Nginx
############################################################

# Set the base image to Ubuntu Xenial
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER QuickBox.IO

# Set correct environment variables.
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt-get -qqy update
RUN apt-get -qqy install locales build-essential software-properties-common \
    python-software-properties apt-transport-https
RUN locale-gen en_US.UTF-8 fr_CA.UTF-8
ENV LANG en_US.UTF-8

# Ubuntu mirrors
RUN for i in "" -updates -backports -security; do echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial${i} main restricted universe multiverse"; done > /etc/apt/sources.list

# PHP 7
RUN apt-get update && apt-get install -y software-properties-common systemd \
  && apt-add-repository ppa:ondrej/php && apt-get purge -y software-properties-common \
  && apt-get -qqy update \
  && apt-get install -qqy nginx-light php7.0-fpm php-xdebug supervisor \
  && apt-get clean
RUN mkdir -p /run/php
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
RUN echo 'fastcgi_read_timeout 7200s;' >> /etc/nginx/fastcgi_params
#COPY php.ini /etc/php/7.0/fpm/php.ini
#COPY xdebug.ini /etc/php/mods-available/xdebug.ini

# Nginx
COPY default-nginx-conf-dashboard.conf /etc/nginx/sites-available/default
COPY nginx.conf /etc/nginx/nginx.conf
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV APTLIST="ca-certificates-mono bzip2 libcurl4-openssl-dev wget unzip \
    htop iotop git lsb-release sudo apt-utils nano curl"

# Install packages
RUN apt-get -qqy update && \
    apt-get -qqy install $APTLIST && \
    apt-get -qq clean && \
    apt-get -qqy update && \
    apt-get -qqy upgrade && \

    mkdir -p /opt/quickbox/ && \
    mkdir -p /opt/quickbox/cmd/ && \
    mkdir -p /opt/quickbox/logs/ && \
    mkdir -p /opt/quickbox/dashboard

################## BEGIN INSTALLATION ######################

ADD dashboard /opt/quickbox/dashboard
RUN chown -R www-data:www-data /opt/quickbox/dashboard

ADD usr/import_user /opt/quickbox/usr/import_user
RUN chmod u+x /opt/quickbox/usr/import_user
RUN /opt/quickbox/usr/import_user

##################### INSTALLATION END #####################

RUN service php7.0-fpm restart && service nginx restart

# Expose the default port(s)
EXPOSE 80 443

# Default port to execute the entrypoint (Nginx)
#CMD ["--port 80"]
CMD ["/bin/bash", "nginx", "-g", "daemon off;"]
#CMD /usr/sbin/nginx -g "daemon off;"
#CMD ["nginx", "-g", "daemon off;"]
