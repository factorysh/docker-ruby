build-source-2.5: rubies/stretch/ruby-$(RUBY25)

rubies/stretch/ruby-$(RUBY25):
	make -C . tool-stretch
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="stretch"
	docker run --rm \
		--volume `pwd`/rubies/stretch:/opt/rubies \
		ruby-install:stretch $(RUBY25) $(USER)

image-2.5: build-source-2.5
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY25)
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:2.5 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=$(RUBY25) \
			.

image-2.5-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:2.5 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.5 \
			.

test-2.5: goss
	@printf "Handling %s\\n" "test-2.5"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=2.5
