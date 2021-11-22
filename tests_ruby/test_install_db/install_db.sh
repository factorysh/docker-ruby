#!/bin/sh

VERSION=$(ruby --version | cut -c 6-8)

rm -rf vendor
ln -sf "$RUBY_VERSION/Gemfile" Gemfile
ln -sf "$RUBY_VERSION/Gemfile.lock" Gemfile.lock
# check ruby version
if [ "$(ruby -e "Gem::Version.new('$VERSION') >= Gem::Version.new('2.7') ? puts('0') : puts('1')")" -ne 0 ]
then
	bundle install --path=vendor
else
	bundle config set path vendor
	bundle install
fi
