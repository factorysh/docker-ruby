
include Makefile.lint
include Makefile.build_args

.PHONY: rubies

RUBY_INSTALL_VERSION=0.8.3
RUBY24 := 2.4.10
RUBY25 := 2.5.9
RUBY26 := 2.6.8
RUBY30 := 3.0.2
GOSS_VERSION := 0.3.9

USER=$(shell id -u)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster
	docker pull bearstech/debian:bullseye

push:
	docker push bearstech/ruby:2.3
	docker push bearstech/ruby-dev:2.3
	docker push bearstech/ruby:2.4
	docker push bearstech/ruby-dev:2.4
	docker push bearstech/ruby:2.5
	docker push bearstech/ruby-dev:2.5
	docker push bearstech/ruby:2.6
	docker push bearstech/ruby-dev:2.6
	docker push bearstech/ruby:2.7
	docker push bearstech/ruby-dev:2.7
	docker push bearstech/ruby:2.7-bullseye
	docker push bearstech/ruby-dev:2.7-bullseye
	docker push bearstech/ruby:3.0
	docker push bearstech/ruby-dev:3.0
	docker push bearstech/sinatra-dev

remove_image:
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/sinatra-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/ruby-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/ruby") || true

build: | \
	build-23 \
	build-24 \
	build-25 \
	build-26 \
	build-27 \
	build-30


build-23: | tool-stretch image_apt-stretch-2.3 image_apt_dev-stretch-2.3 test-2.3

build-24: | tool-stretch image_install-stretch-$(RUBY24) image_install_dev-2.4 test-2.4

build-25: | tool-stretch image_install-stretch-$(RUBY25) image_install_dev-2.5 test-2.5

build-26: | tool-buster image_install-buster-$(RUBY26) image_install_dev-2.6 test-2.6

build-27: | image_apt-bullseye-2.7 image_apt_dev-bullseye-2.7 test-2.7
	docker tag bearstech/ruby:2.7 bearstech/ruby:2.7-bullseye
	docker tag bearstech/ruby-dev:2.7 bearstech/ruby-dev:2.7-bullseye


build-30: | tool-bullseye image_install-bullseye-$(RUBY30) image_install_dev-3.0 test-3.0

build-sinatra: image-sinatra-dev

empty_context:
	rm -rf rubies/empty
	mkdir -p rubies/empty

image_apt-%:
	$(eval debian_version=$(shell echo $@ | cut -d- -f2))
	$(eval tag=$(shell echo $@ | cut -d- -f3-))
	$(eval version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby:$(tag) \
		-f Dockerfile.apt \
		--build-arg DEBIAN_DISTRO=$(debian_version) \
		--build-arg RUBY_VERSION=$(version) \
		.

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
		rubies/empty

image_install-%:
	$(eval debian_version=$(shell echo $@ | cut -d- -f2))
	$(eval version=$(shell echo $@ | cut -d- -f3))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	$(eval minor_version=$(shell echo $(version) | cut -d. -f2))
	mkdir -p rubies/$@/ruby
	docker run --rm \
		--volume `pwd`/rubies/$@:/opt/rubies \
		ruby-install:(debian_version) $(version) $(USER)
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby:$(major_version).$(minor_version) \
		-f Dockerfile.ruby-install \
		--build-arg DEBIAN_DISTRO=stretch \
		--build-arg RUBY_VERSION=$(version) \
		rubies/$@

image_install_dev-%: empty_context
	$(eval version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/ruby-dev:$(version) \
		-f Dockerfile.ruby-install-dev \
		--build-arg RUBY_FROM_TAG=$(version) \
		rubies/empty

test-%: goss
	$(eval version=$(shell echo $@ | cut -d- -f2))
	@printf "Handling %s\\n" "$@"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=$(version)

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
		rubies/empty

image-dev: image-2.3-dev image-2.4-dev image-2.5-dev image-2.6-dev image-2.7-dev image-2.7-dev-bullseye image-3.0-dev image-sinatra-dev
image: image-2.3 image-2.4 image-2.5 image-2.6 image-2.7 image-2.7-bullseye image-3.0
images: image image-dev

clean:
	rm -rf rubies bin done
	rm .dockerignore

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_ruby/test_install_db/bin/goss: bin/goss
	mkdir -p tests_ruby/test_install_db/bin
	cp -r bin/goss tests_ruby/test_install_db/bin/goss

goss: bin/goss tests_ruby/test_install_db/bin/goss

test-all: | test-2.3 test-2.4 test-2.5 test-2.6 test-2.7 test-2.7-bullseye test-3.0

down:

tests: test-all
