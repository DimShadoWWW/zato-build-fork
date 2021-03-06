#!/bin/bash

# Adapted from dw's zatosource/zato/.travis/setup.sh
#
# Expose a 'run' command that runs code either directly on this VM, or if IMAGE
# is set, in a Docker container on the VM instead. The mode where IMAGE is
# unset is intended for later use with OS X.
#
# When running in container mode, wire up various cache directories within the
# container back to a directory that Travis knows to keep a copy of. This
# causes package lists and PyPI source archives to be cached.
#
# In either case, "/tmp/zato-build" contains the checked out Git repository.
#
# Usage:
#   . $TRAVIS_BUILD_DIR/.travis/setup.sh
#   run cmd...
#

set -xe
sudo mkdir -p /tmp/travis-cache/root/.cache/pip
sudo mkdir -p /tmp/travis-cache/var/cache/apk
sudo mkdir -p /tmp/travis-cache/var/cache/apt
sudo mkdir -p /tmp/travis-cache/var/lib/apt
sudo mkdir -p /tmp/travis-cache/var/cache/yum

run() {
  if test -n "$IMAGE" ; then
    docker exec target "$@"
  else
    "$@"
  fi
}

if test -n "$IMAGE" ; then
  # chown everything to root so perms within container work.
  sudo chown -R root: /tmp/travis-cache

  # Arrange for the container to be downloaded and started.
  docker run \
    --name target \
    --volume $TRAVIS_BUILD_DIR:/tmp/zato-build \
    --volume /tmp/travis-cache/root/.cache/pip:/root/.cache/pip \
    --volume /tmp/travis-cache/var/cache/apk:/var/cache/apk \
    --volume /tmp/travis-cache/var/cache/apt:/var/cache/apt \
    --volume /tmp/travis-cache/var/lib/apt:/var/lib/apt \
    --volume /tmp/travis-cache/var/cache/yum:/var/cache/yum \
    --detach \
    "$IMAGE" \
    sleep 86400

  # Some official images lack sudo and/or bash.
  # Also add developer keys for Alpine.

  if test "${IMAGE:0:6}" = "centos" ; then
    run yum -y install sudo
  elif test "${IMAGE:0:6}" = "alpine" ; then
    run /bin/sh -ec "apk update && apk upgrade && apk add sudo bash && exec abuild-keygen -an"
  elif test "${IMAGE:0:6}" = "ubuntu" -o "${IMAGE:0:6}" = "debian" ; then
    run /bin/sh -ec "apt-get update && exec apt-get -y install sudo"
  fi

  # chown everything to Travis UID so caching succeeds.
  trap "sudo chown -R $(whoami): /tmp/travis-cache" EXIT
else
  ln -sf `pwd` /tmp/zato-build
fi
