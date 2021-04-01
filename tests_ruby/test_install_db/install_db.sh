#!/bin/sh

VERSION=$(ruby --version | cut -c 6-8)

rm -rf vendor
ln -sf "$RUBY_VERSION/Gemfile" Gemfile
ln -sf "$RUBY_VERSION/Gemfile.lock" Gemfile.lock
if [ "$VERSION" = "2.7" ]; then
	bundle config set path vendor
	bundle install
else
	bundle install --path=vendor
fi
