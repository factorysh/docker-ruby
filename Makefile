
include Makefile.lint
include Makefile.build_args

.PHONY: rubies

# 2.3 is in Stretch
RUBY23 := 2.3.8
RUBY24 := 2.4.5
RUBY25 := 2.5.6
GOSS_VERSION := 0.3.9

USER=$(shell id -u)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
STRETCH_ID=$(shell docker images  bearstech/debian:stretch --format="{{.ID}}" --quiet)
STRETCH_DEV_ID=$(shell docker images  bearstech/debian-dev:stretch --format="{{.ID}}" --quiet)

DOCKERFILE_APT=$(shell sha1sum Dockerfile.apt | cut -c 1-40)
DOCKERFILE_APT_DEV=$(shell sha1sum Dockerfile.apt-dev | cut -c 1-40)
DOCKERFILE_RUBY_INSTALL=$(shell sha1sum Dockerfile.ruby-install | cut -c 1-40)
DOCKERFILE_RUBY_INSTALL_DEV=$(shell sha1sum Dockerfile.ruby-install-dev | cut -c 1-40)
DOCKERFILE_SINATRA_DEV=$(shell sha1sum Dockerfile.sinatra-dev | cut -c 1-40)
DOCKERFILE_TOOL=$(shell sha1sum Dockerfile.tool | cut -c 1-40)

MK23=$(shell sha1sum ruby23.mk | cut -c 1-40)
MK24=$(shell sha1sum ruby24.mk | cut -c 1-40)
MK25=$(shell sha1sum ruby25.mk | cut -c 1-40)

DONE23=image-$(STRETCH_ID)_$(MK23)-$(DOCKERFILE_APT)-$(DOCKERFILE_APT_DEV)-2.3.done
DONE24=image-$(STRETCH_ID)_$(MK24)-$(DOCKERFILE_RUBY_INSTALL)-$(DOCKERFILE_RUBY_INSTALL_DEV)-$(RUBY24).done
DONE25=image-$(STRETCH_ID)_$(MK25)-$(DOCKERFILE_RUBY_INSTALL)-$(DOCKERFILE_RUBY_INSTALL_DEV)-$(RUBY25).done
DONE_SINATRA=image-$(STRETCH_DEV_ID)-$(GIT_VERSION)-$(BRANCH)-sinatra.done

include *.mk

all: pull build

pull:
	docker pull bearstech/debian:stretch

push:
	docker push bearstech/ruby:2.3
	docker push bearstech/ruby-dev:2.3
	docker push bearstech/ruby:2.4
	docker push bearstech/ruby-dev:2.4
	docker push bearstech/ruby:2.5
	docker push bearstech/ruby-dev:2.5
	docker push bearstech/sinatra-dev

remove_image:
	docker rmi bearstech/ruby:2.3
	docker rmi bearstech/ruby-dev:2.3
	docker rmi bearstech/ruby:2.4
	docker rmi bearstech/ruby-dev:2.4
	docker rmi bearstech/ruby:2.5
	docker rmi bearstech/ruby-dev:2.5
	docker rmi bearstech/sinatra-dev

build: | \
	tools \
	done23 \
	done24 \
	done25 \
	done-sinatra

done:
	mkdir -p done

done23:
ifeq (,$(wildcard done/$(DONE23)))
	$(MAKE) done/$(DONE23)
endif

done24:
ifeq (,$(wildcard done/$(DONE24)))
	$(MAKE) done/$(DONE24)
endif

done25:
ifeq (,$(wildcard done/$(DONE25)))
	$(MAKE) done/$(DONE25)
endif

done-sinatra:
ifeq (,$(wildcard done/$(DONE_SINATRA)))
	$(MAKE) done/$(DONE_SINATRA)
endif

done/$(DONE23): | done image-2.3 image-2.3-dev test-2.3
	rm -f done/image-*-2.3.done
	touch done/$(DONE23)

done/$(DONE24): | done image-2.4 image-2.4-dev test-2.4
	rm -f done/image-*-2.4.*.done
	touch done/$(DONE24)

done/$(DONE25): | done image-2.5 image-2.5-dev test-2.5
	rm -f done/image-*-2.5.*.done
	touch done/$(DONE25)

done/$(DONE_SINATRA): | done image-sinatra-dev
	rm -f done/image-*-sinatra.done
	touch done/$(DONE_SINATRA)

## Docker ignore utils

ignore_all_rubies:
	echo "rubies" > .dockerignore

DOCKER_IGNORE_RUBIES_DIR_REV := ""
DOCKER_IGNORE_RUBIES_DEPTH := "2"

rubies_docker_ignore:
	find rubies \
		-mindepth $(DOCKER_IGNORE_RUBIES_DEPTH) \
		-maxdepth $(DOCKER_IGNORE_RUBIES_DEPTH) | \
	(grep -v $(DOCKER_IGNORE_RUBIES_DIR_REV) || true) > .dockerignore

## Tools

tool-stretch:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t ruby-install:stretch \
		-f Dockerfile.tool \
		--build-arg DEBIAN_DISTRO=stretch \
		.

tools: tool-stretch

image-sinatra-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/sinatra-dev \
		-f Dockerfile.sinatra-dev \
		.

image-dev: image-2.0-dev image-2.1-dev image-2.2-dev image-2.3-dev image-2.4-dev image-2.5-dev

clean:
	rm -rf rubies bin done
	rm .dockerignore

bin/goss-$(GOSS_VERSION):
	mkdir -p bin
	curl -o bin/goss-$(GOSS_VERSION) -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss-$(GOSS_VERSION)

bin/goss: bin/goss-$(GOSS_VERSION)
	ln -sf goss-$(GOSS_VERSION) bin/goss

tests_ruby/test_install_db/bin/goss: bin/goss
	mkdir -p tests_ruby/test_install_db/bin
	cp -r bin/goss-$(GOSS_VERSION) tests_ruby/test_install_db/bin/goss-$(GOSS_VERSION)
	cp -r bin/goss tests_ruby/test_install_db/bin/goss

goss: tests_ruby/test_install_db/bin/goss

test-all: | test-2.3 test-2.4 test-2.5

down:

tests: test-all
