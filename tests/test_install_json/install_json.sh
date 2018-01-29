#!/bin/sh

apt-get update
apt-get install -y libgmp-dev
bundle install --path=vendor
ruby -e "require 'json'; puts ({hello: 'world'}).to_json"
