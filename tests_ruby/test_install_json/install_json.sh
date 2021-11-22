#!/bin/sh

apt-get update
apt-get install -y libgmp-dev
rm -rf vendor
# check ruby version
if [ "$(ruby -e "Gem::Version.new('$VERSION') >= Gem::Version.new('2.7') ? puts('0') : puts('1')")" -ne 0 ]
then
	bundle install --path=vendor
else
	bundle config set path vendor
	bundle install
fi
