.PHONY: rubies

RUBY20 := 2.0.0-p648
# 2.1 is in Jessie
RUBY22 := 2.2.7
# 2.3 is in Stretch
RUBY23 := 2.3.8
RUBY24 := 2.4.5
RUBY25 := 2.5.3
GOSS_VERSION := 0.3.5

USER=$(shell id -u)
GIT_VERSION=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
JESSIE_ID=$(shell docker images  bearstech/debian:jessie --format="{{.ID}}" --quiet)
STRETCH_ID=$(shell docker images  bearstech/debian:stretch --format="{{.ID}}" --quiet)
STRETCH_DEV_ID=$(shell docker images  bearstech/debian-dev:stretch --format="{{.ID}}" --quiet)

DONE20=image-$(JESSIE_ID)-$(GIT_VERSION)-$(BRANCH)-20.done
DONE21=image-$(JESSIE_ID)-$(GIT_VERSION)-$(BRANCH)-21.done
DONE22=image-$(JESSIE_ID)-$(GIT_VERSION)-$(BRANCH)-22.done
DONE23=image-$(STRETCH_ID)_$(STRETCH_DEV_ID)-$(GIT_VERSION)-$(BRANCH)-23.done
DONE24=image-$(STRETCH_ID)_$(STRETCH_DEV_ID)-$(GIT_VERSION)-$(BRANCH)-24.done
DONE25=image-$(STRETCH_ID)_$(STRETCH_DEV_ID)-$(GIT_VERSION)-$(BRANCH)-25.done
DONE_SINATRA=image-$(STRETCH_DEV_ID)-$(GIT_VERSION)-$(BRANCH)-sinatra.done

include *.mk

all: pull build

pull:
	docker pull bearstech/debian:jessie
	docker pull bearstech/debian:stretch

push:
	docker push bearstech/ruby:2.0
	docker push bearstech/ruby-dev:2.0
	docker push bearstech/ruby:2.1
	docker push bearstech/ruby-dev:2.1
	docker push bearstech/ruby:2.2
	docker push bearstech/ruby-dev:2.2
	docker push bearstech/ruby:2.3
	docker push bearstech/ruby-dev:2.3
	docker push bearstech/ruby:2.4
	docker push bearstech/ruby-dev:2.4
	docker push bearstech/ruby:2.5
	docker push bearstech/ruby-dev:2.5
	docker push bearstech/ruby:2.3-jessie
	docker push bearstech/ruby-dev:2.3-jessie
	docker push bearstech/sinatra-dev

remove_image:
	docker rmi bearstech/ruby:2.0
	docker rmi bearstech/ruby-dev:2.0
	docker rmi bearstech/ruby:2.1
	docker rmi bearstech/ruby-dev:2.1
	docker rmi bearstech/ruby:2.2
	docker rmi bearstech/ruby-dev:2.2
	docker rmi bearstech/ruby:2.3
	docker rmi bearstech/ruby-dev:2.3
	docker rmi bearstech/ruby:2.4
	docker rmi bearstech/ruby-dev:2.4
	docker rmi bearstech/ruby:2.5
	docker rmi bearstech/ruby-dev:2.5
	docker rmi bearstech/ruby:2.3-jessie
	docker rmi bearstech/ruby-dev:2.3-jessie
	docker rmi bearstech/sinatra-dev

build: | \
	tools \
	done20 \
	done21 \
	done22 \
	done23 \
	done24 \
	done25 \
	done-sinatra

done:
	mkdir -p done

done20:
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) done/$(DONE20)
endif

done21:
ifeq (,$(wildcard done/$(DONE21)))
	$(MAKE) done/$(DONE21)
endif

done22:
ifeq (,$(wildcard done/$(DONE22)))
	$(MAKE) done/$(DONE22)
endif

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

done/$(DONE20): | done image-2.0 image-2.0-dev test-2.0
	rm -f done/image-*-20.done
	touch done/$(DONE20)

done/$(DONE21): | done image-2.1 image-2.1-dev test-2.1
	rm -f done/image-*-21.done
	touch done/$(DONE21)

done/$(DONE22): | done image-2.2 image-2.2-dev test-2.2
	rm -f done/image-*-22.done
	touch done/$(DONE22)

done/$(DONE23): | done image-2.3 image-2.3-dev image-2.3-jessie image-2.3-jessie-dev test-2.3
	rm -f done/image-*-23.done
	touch done/$(DONE23)

done/$(DONE24): | done image-2.4 image-2.4-dev test-2.4
	rm -f done/image-*-24.done
	touch done/$(DONE24)

done/$(DONE25): | done image-2.5 image-2.5-dev test-2.5
	rm -f done/image-*-25.done
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

tool-jessie:
	make -C . ignore_all_rubies
	docker build -t ruby-install:jessie -f Dockerfile.tool --build-arg DEBIAN_DISTRO=jessie .

tool-stretch:
	make -C . ignore_all_rubies
	docker build -t ruby-install:stretch -f Dockerfile.tool --build-arg DEBIAN_DISTRO=stretch .

tools: tool-jessie tool-stretch

image-sinatra-dev:
	make -C . ignore_all_rubies
	docker build -t bearstech/sinatra-dev -f Dockerfile.sinatra-dev .

image-dev: image-2.0-dev image-2.1-dev image-2.2-dev image-2.3-dev image-2.4-dev image-2.5-dev

clean:
	rm -rf rubies bin done
	rm .dockerignore

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

tests_ruby/test_install_db/bin/goss: bin/goss
	mkdir tests_ruby/test_install_db/bin
	cp -r bin/goss tests_ruby/test_install_db/bin/goss

goss: tests_ruby/test_install_db/bin/goss

test-all: | test-2.0 test-2.1 test-2.2 test-2.3 test-2.3-jessie test-2.4 test-2.5

tests:
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.0
endif
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.1
endif
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.2
endif
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.3 test-2.3-jessie
endif
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.4
endif
ifeq (,$(wildcard done/$(DONE20)))
	$(MAKE) test-2.5
endif
