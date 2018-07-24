.PHONY: rubies tests

RUBY20 := 2.0.0-p648
# 2.1 is in Jessie
RUBY22 := 2.2.7
# 2.3 is in Stretch
RUBY23 := 2.3.7
RUBY24 := 2.4.4
RUBY25 := 2.5.1
GOSS_VERSION := 0.3.5

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

build: tool \
	image-2.0 image-2.0-dev \
	image-2.1 image-2.1-dev \
	image-2.2 image-2.2-dev \
	image-2.3 image-2.3-dev \
	image-2.4 image-2.4-dev \
	image-2.5 image-2.5-dev \
	image-2.3-jessie image-2.3-jessie-dev \
	image-sinatra-dev \

tool: tool-jessie tool-stretch

tool-jessie:
	docker build -t ruby-install:jessie -f Dockerfile.tool --build-arg debian=jessie .

tool-stretch:
	docker build -t ruby-install:stretch -f Dockerfile.tool --build-arg debian=stretch .

## Download and install ressources

build-source-2.0: rubies/jessie/ruby-$(RUBY20)

rubies/jessie/ruby-$(RUBY20):
	docker run --rm --volume `pwd`/rubies/jessie:/opt/rubies ruby-install:jessie \
		bash -c 'apt-get update && ruby-install --no-install-deps --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY20)'

build-source-2.2: rubies/jessie/ruby-$(RUBY22)

rubies/jessie/ruby-$(RUBY22):
	docker run --rm --volume `pwd`/rubies/jessie:/opt/rubies ruby-install:jessie \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY22)'

build-source-2.3-jessie: rubies/jessie/ruby-$(RUBY23)

rubies/jessie/ruby-$(RUBY23): tool-jessie
	docker run --rm --volume `pwd`/rubies/jessie:/opt/rubies ruby-install:jessie \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby 2.3'

build-source-2.4: rubies/stretch/ruby-$(RUBY24)

rubies/stretch/ruby-$(RUBY24):
	docker run --rm --volume `pwd`/rubies/stretch:/opt/rubies ruby-install:stretch \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY24)'

build-source-2.5: rubies/stretch/ruby-$(RUBY25)

rubies/stretch/ruby-$(RUBY25):
	docker run --rm --volume `pwd`/rubies/stretch:/opt/rubies ruby-install:stretch \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY25)'

## Build each image using ressources

# Default docker images

image-2.0: build-source-2.0
	docker build -t bearstech/ruby:2.0 --build-arg ruby_version=$(RUBY20) -f Dockerfile.jessie .

image-2.1:
	docker build -t bearstech/ruby:2.1 -f Dockerfile.21 .

image-2.2: build-source-2.2
	docker build -t bearstech/ruby:2.2 --build-arg ruby_version=$(RUBY22) -f Dockerfile.jessie .

image-2.3:
	docker build -t bearstech/ruby:2.3 -f Dockerfile.23 .

image-2.3-jessie: build-source-2.3-jessie
	docker build -t bearstech/ruby:2.3-jessie --build-arg ruby_version=$(RUBY23) -f Dockerfile.jessie .

image-2.4: build-source-2.4
	docker build -t bearstech/ruby:2.4 --build-arg ruby_version=$(RUBY24) -f Dockerfile.stretch .

image-2.5: build-source-2.5
	docker build -t bearstech/ruby:2.5 --build-arg ruby_version=$(RUBY25) -f Dockerfile.stretch .

# Bearstech Dev images

image-2.0-dev:
	docker build -t bearstech/ruby-dev:2.0 --build-arg ruby_from=ruby:2.0 -f Dockerfile.dev .

image-2.1-dev:
	docker build -t bearstech/ruby-dev:2.1 -f Dockerfile.21-dev .

image-2.2-dev:
	docker build -t bearstech/ruby-dev:2.2 --build-arg ruby_from=ruby:2.2 -f Dockerfile.dev .

image-2.3-dev:
	docker build -t bearstech/ruby-dev:2.3 -f Dockerfile.23-dev .

image-2.3-jessie-dev:
	docker build -t bearstech/ruby-dev:2.3-jessie --build-arg ruby_from=ruby:2.3-jessie -f Dockerfile.dev .

image-2.4-dev:
	docker build -t bearstech/ruby-dev:2.4 --build-arg ruby_from=ruby:2.4 -f Dockerfile.dev .

image-2.5-dev:
	docker build -t bearstech/ruby-dev:2.5 --build-arg ruby_from=ruby:2.5 -f Dockerfile.dev .

image-sinatra-dev:
	docker build -t bearstech/sinatra-dev -f Dockerfile.sinatra-dev .

clean:
	rm -rf rubies bin

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-2.5: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.5 \
		goss -g ruby-dev.yaml --vars vars/2_5.yaml validate --max-concurrent 4 --format documentation

test-2.4: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.4 \
		goss -g ruby-dev.yaml --vars vars/2_4.yaml validate --max-concurrent 4 --format documentation

test-2.3: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.3 \
		goss -g ruby-dev.yaml --vars vars/2_3.yaml validate --max-concurrent 4 --format documentation

test-2.3-jessie: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.3-jessie \
		goss -g ruby-dev.yaml --vars vars/2_3.yaml validate --max-concurrent 4 --format documentation

test-2.2: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.2 \
		goss -g ruby-dev.yaml --vars vars/2_2.yaml validate --max-concurrent 4 --format documentation

test-2.1: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.1 \
		goss -g ruby-dev.yaml --vars vars/2_1.yaml validate --max-concurrent 4 --format documentation

test-2.0: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/ruby-dev:2.0 \
		goss -g ruby-dev.yaml --vars vars/2_0.yaml validate --max-concurrent 4 --format documentation

tests: test-2.5 test-2.4 test-2.3 test-2.2 test-2.1 test-2.0 test-2.3-jessie
