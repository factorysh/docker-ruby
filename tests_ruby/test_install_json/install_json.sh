#!/bin/sh

apt-get update
apt-get install -y libgmp-dev
rm -rf vendor
# check ruby version
ruby -e "Gem::Version.new('$VERSION') >= Gem::Version.new('2.7') ? exit(0) : exit(1)"

if [ $? -ne 0 ]
then
	bundle install --path=/ruby/vendor
else
	bundle config set path /ruby/vendor
	bundle install
fi
