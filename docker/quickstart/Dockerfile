# Zato
#
# VERSION 0.0.1

FROM ubuntu:14.04
MAINTAINER Rafał Krysiak <rafal@zato.io>

# Install helper programs used during Zato installation
RUN apt-get update && apt-get install -y apt-transport-https \
    python-software-properties \
    software-properties-common \
    curl 

# Install Redis
RUN add-apt-repository -y ppa:rwky/redis \
    && apt-get -y update \
    && apt-get install -y redis-server

# Add the package signing key
RUN curl -s https://zato.io/repo/zato-0CBD7F72.pgp.asc | sudo apt-key add -

# Add Zato repo to your apt
# update sources and install Zato
RUN apt-add-repository https://zato.io/repo/dev/ubuntu
RUN apt-get update && apt-get install -y zato

# Create work environment for Zato 2.0.0

# Switch to zato user and create Zato environment
USER zato

# Sets variable 'zato' to path '/opt/zato/2.0/bin/zato'
ENV zato /opt/zato/2.0.0/bin/zato

RUN mkdir -p env/qs-1
RUN rm -rf env/qs-1 && mkdir -p env/qs-1

WORKDIR env/qs-1
RUN $zato quickstart create . sqlite localhost 6379 --verbose --kvdb_password ""
# RUN $zato check-config server1
# RUN $zato check-config server2

# Switch back to root
# USER root