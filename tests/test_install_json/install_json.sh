#!/bin/sh

apt-get update
apt-get install -y libgmp-dev
rm -rf vendor
bundle install --path=vendor
bundle exec ruby -e "require 'json'; puts ({hello: 'world'}).to_json"
