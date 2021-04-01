build-source-2.7: rubies/buster/ruby-$(RUBY27)

rubies/buster/ruby-$(RUBY27):
	make -C . tool-buster
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="buster"
	docker run --rm \
		--volume `pwd`/rubies/buster:/opt/rubies \
		ruby-install:buster $(RUBY27) $(USER)

image-2.7: build-source-2.7
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY27)
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:2.7 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=buster \
			--build-arg RUBY_VERSION=$(RUBY27) \
			.

image-2.7-bullseye:
	docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:2.7-bullseye \
			-f Dockerfile.apt \
			--build-arg DEBIAN_DISTRO=bullseye \
			--build-arg RUBY_VERSION=2.7 \
			.

image-2.7-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:2.7 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.7 \
			.

image-2.7-dev-bullseye:
	docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:2.7-bullseye \
			-f Dockerfile.apt-dev \
			--build-arg DEBIAN_DISTRO=bullseye \
			--build-arg RUBY_VERSION=2.7 \
			.

test-2.7: bin/goss
	@printf "Handling %s\\n" "test-2.7"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=2.7
