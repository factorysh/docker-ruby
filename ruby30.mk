build-source-3.0: rubies/bullseye/ruby-$(RUBY30)

rubies/bullseye/ruby-$(RUBY30):
	make -C . tool-bullseye
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="bullseye"
	docker run --rm \
		--volume `pwd`/rubies/bullseye:/opt/rubies \
		ruby-install:bullseye $(RUBY30) $(USER)

image-3.0: build-source-3.0
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY30)
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:3.0 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=bullseye \
			--build-arg RUBY_VERSION=$(RUBY30) \
			.

image-3.0-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:3.0 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=3.0 \
			.


test-3.0: goss
	@printf "Handling %s\\n" "test-3.0"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=3.0
