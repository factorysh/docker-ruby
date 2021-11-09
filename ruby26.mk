build-source-2.6: rubies/buster/ruby-$(RUBY26)

rubies/buster/ruby-$(RUBY26):
	make -C . tool-buster
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="buster"
	docker run --rm \
		--volume `pwd`/rubies/buster:/opt/rubies \
		ruby-install:buster $(RUBY26) $(USER)

image-2.6: build-source-2.6
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY26)
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:2.6 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=buster \
			--build-arg RUBY_VERSION=$(RUBY26) \
			.

image-2.6-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:2.6 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.6 \
			.

test-2.6: goss
	@printf "Handling %s\\n" "test-2.6"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=2.6
