Testing image with Goss
=======================

Tests are running inside container context, using volumes and lazy downloaded `goss` binary.

Test are running with the `Makefile` in parent folder, with `make tests`.

`ruby-dev.yaml`: main playbook. Imports all tests.

`*.yaml` : differents tests.

`vars` : one YAML containing settings per ruby versions.

`test_install_json` : Gemfile + Gemfile.lock and the dummy shell script for installing stuff with bundler.

