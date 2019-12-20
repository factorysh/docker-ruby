#!/bin/sh

rm -rf vendor
ln -sf "$RUBY_VERSION/Gemfile" Gemfile
ln -sf "$RUBY_VERSION/Gemfile.lock" Gemfile.lock
bundle install --path=vendor
