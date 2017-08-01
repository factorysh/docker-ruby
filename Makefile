.PHONY: rubies

RUBY20 := 2.0.0-p648
# 2.1 is in Jessie 
RUBY22 := 2.2.7
# 2.3 is in Stretch
RUBY24 := 2.4.1

all: pull tool images

pull:
	docker pull bearstech/debian:jessie
	docker pull bearstech/debian:stretch

images: image-2.0 image-2.0-dev \
	image-2.1 image-2.1-dev \
	image-2.2 image-2.2-dev \
	image-2.3 image-2.3-dev \
	image-2.4 image-2.4-dev

rubies: 2.0 2.2 2.4

tool: tool-jessie tool-stretch

tool-jessie:
	docker build -t ruby-install:jessie -f Dockerfile.tool --build-arg debian=jessie .

tool-stretch:
	docker build -t ruby-install:stretch -f Dockerfile.tool --build-arg debian=stretch .

2.0: rubies/jessie/ruby-$(RUBY20)

rubies/jessie/ruby-$(RUBY20):
	docker run --rm --volume `pwd`/rubies/jessie:/opt/rubies ruby-install:jessie \
		bash -c 'apt-get update && ruby-install --no-install-deps --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY20)'

image-2.0: 2.0
	docker build -t bearstech/ruby:2.0 --build-arg ruby_version=$(RUBY20) -f Dockerfile.jessie .

image-2.0-dev:
	docker build -t bearstech/ruby-dev:2.0 --build-arg ruby_from=ruby:2.0 -f Dockerfile.dev .

image-2.1:
	docker build -t bearstech/ruby:2.1 -f Dockerfile.21 .

image-2.1-dev:
	docker build -t bearstech/ruby-dev:2.1 -f Dockerfile.21-dev .

2.2: rubies/jessie/ruby-$(RUBY22)

rubies/jessie/ruby-$(RUBY22):
	docker run --rm --volume `pwd`/rubies/jessie:/opt/rubies ruby-install:jessie \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY22)'

image-2.2: 2.2
	docker build -t bearstech/ruby:2.2 --build-arg ruby_version=$(RUBY22) -f Dockerfile.jessie .

image-2.2-dev:
	docker build -t bearstech/ruby-dev:2.2 --build-arg ruby_from=ruby:2.2 -f Dockerfile.dev .

image-2.3:
	docker build -t bearstech/ruby:2.3 -f Dockerfile.23 .

image-2.3-dev:
	docker build -t bearstech/ruby-dev:2.3 -f Dockerfile.23-dev .

2.4: rubies/stretch/ruby-$(RUBY24)

rubies/stretch/ruby-$(RUBY24):
	docker run --rm --volume `pwd`/rubies/stretch:/opt/rubies ruby-install:stretch \
		bash -c 'apt-get update && ruby-install --rubies-dir /opt/rubies --jobs=2 --no-reinstall ruby $(RUBY24)'

image-2.4: 2.4
	docker build -t bearstech/ruby:2.4 --build-arg ruby_version=$(RUBY24) -f Dockerfile.stretch .

image-2.4-dev:
	docker build -t bearstech/ruby-dev:2.4 --build-arg ruby_from=ruby:2.4 -f Dockerfile.dev .
