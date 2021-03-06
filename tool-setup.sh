#!/bin/sh

if [ ! $# = 2 ]; then
  exit 1
fi

set -eux

apt-get update
ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby "${1}"
chown -R "${2}" /opt/rubies
