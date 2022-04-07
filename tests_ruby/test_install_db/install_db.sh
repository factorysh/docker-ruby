#!/bin/sh

VERSION=$(ruby --version | cut -c 6-8)

rm -rf vendor
ln -sf "$RUBY_VERSION/Gemfile" Gemfile
ln -sf "$RUBY_VERSION/Gemfile.lock" Gemfile.lock

if ! bundle install --path=vendor
then
    # old bundler versions do not support --path
	bundle config set --local path 'vendor'
	bundle install
fi
