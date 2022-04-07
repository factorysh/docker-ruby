
include Makefile.lint
include Makefile.build_args

.PHONY: rubies

RUBY_INSTALL_VERSION=0.8.3
RUBY24 := 2.4.10
RUBY26 := 2.6.9
RUBY31 := 3.1.1
GOSS_VERSION := 0.3.9

BUILD_DIR?=$(shell pwd)/rubies/
USER=$(shell id -u)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster
	docker pull bearstech/debian:bullseye

push-%:
	$(eval version=$(shell echo $@ | cut -d- -f2))
	docker push bearstech/python:$(version)
	docker push bearstech/python-dev:$(version)

push: push-2.5 push-2.7 push-2.7-bullseye

remove_image:
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/sinatra-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/ruby-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/ruby") || true

build: | \
	build-25 \
	build-27


build-23: | image_apt-stretch-2.3 image_apt_dev-stretch-2.3

build-24: | tool-stretch image_install-stretch-$(RUBY24) image_install_dev-2.4

build-25: | image_apt-buster-2.5 image_apt_dev-buster-2.5

build-26: | tool-buster image_install-buster-$(RUBY26) image_install_dev-2.6

build-27: | image_apt-bullseye-2.7 image_apt_dev-bullseye-2.7
	docker tag bearstech/ruby:2.7 bearstech/ruby:2.7-bullseye
	docker tag bearstech/ruby-dev:2.7 bearstech/ruby-dev:2.7-bullseye

build-31: | tool-bullseye image_install-bullseye-$(RUBY31) image_install_dev-3.1

build-sinatra: image-sinatra-dev

empty_context:
	rm -rf $(BUILD_DIR)/empty
	mkdir -p $(BUILD_DIR)/empty

## Install with apt

image_apt-%: empty_context
	$(eval debian_version=$(shell echo $@ | cut -d- -f2))
	$(eval tag=$(shell echo $@ | cut -d- -f3-))
	$(eval version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby:$(tag) \
		-f Dockerfile.apt \
		--build-arg DEBIAN_DISTRO=$(debian_version) \
		--build-arg RUBY_VERSION=$(version) \
		$(BUILD_DIR)/empty

image_apt_dev-%: empty_context
	$(eval debian_version=$(shell echo $@ | cut -d- -f2))
	$(eval tag=$(shell echo $@ | cut -d- -f3-))
	$(eval version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby-dev:$(tag) \
		-f Dockerfile.apt-dev \
		--build-arg DEBIAN_DISTRO=$(debian_version) \
		--build-arg RUBY_VERSION=$(version) \
		$(BUILD_DIR)/empty

## Install with ruby install

image_install-%:
	$(eval debian_version=$(shell echo $@ | cut -d- -f2))
	$(eval version=$(shell echo $@ | cut -d- -f3))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	$(eval minor_version=$(shell echo $(version) | cut -d. -f2))
	# compile ruby iif not done yet
	mkdir -p $(BUILD_DIR)/$@
	# only compile ruby if needed
	[ -e $(BUILD_DIR)/$@.done ] || \
	docker run --rm \
		--volume $(BUILD_DIR)/$@:/opt/rubies \
		ruby-install:$(debian_version) $(version) $(USER)
	touch $(BUILD_DIR)/$@.done
	# build image using compiled ruby
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby:$(major_version).$(minor_version) \
		-f Dockerfile.ruby-install \
		--build-arg DEBIAN_DISTRO=$(debian_version) \
		--build-arg RUBY_VERSION=$(version) \
		$(BUILD_DIR)/$@

image_install_dev-%: empty_context
	$(eval version=$(shell echo $@ | cut -d- -f2))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby-dev:$(version) \
		-f Dockerfile.ruby-install-dev \
		--build-arg RUBY_FROM_TAG=$(version) \
		$(BUILD_DIR)/empty

## Tools

tool-%:
	$(eval debian_version=$(shell echo $@ | cut -d- -f2-))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t ruby-install:$(debian_version) \
		-f tool/Dockerfile \
		--build-arg RUBY_INSTALL_VERSION=$(RUBY_INSTALL_VERSION) \
		--build-arg DEBIAN_DISTRO=$(debian_version) \
		tool/

tools: tool-stretch tool-buster tool-bullseye

image-sinatra-dev: empty_context
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/sinatra-dev \
		-f Dockerfile.sinatra-dev \
		$(BUILD_DIR)/empty

clean:
	rm -rf rubies bin tests_ruby/test_install_db/bin

## Tests

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_ruby/test_install_db/bin/goss: bin/goss
	mkdir -p tests_ruby/test_install_db/bin
	cp -r bin/goss tests_ruby/test_install_db/bin/goss

test-%: tests_ruby/test_install_db/bin/goss
	$(eval version=$(shell echo $@ | cut -d- -f2))
	@printf "Handling %s\\n" "$@"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=$(version)

tests: | test-2.5 test-2.7 test-2.7-bullseye

down:
