#!/bin/sh

VERSION=$(ruby --version | cut -c 6-8)

rm -rf vendor
ln -sf "$RUBY_VERSION/Gemfile" Gemfile
ln -sf "$RUBY_VERSION/Gemfile.lock" Gemfile.lock
# check ruby version
ruby -e "Gem::Version.new("$VERSION") >= Gem::Version.new('2.7') ? exit(0) : exit(1)"

if [ $? -ne 0 ]
then
	bundle install --path=/ruby/vendor
else
	bundle config set path /ruby/vendor
	bundle install
fi
