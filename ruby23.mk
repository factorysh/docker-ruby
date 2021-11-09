
image-2.3:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby:2.3 \
			-f Dockerfile.apt \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			.

image-2.3-dev:
	make -C . ignore_all_rubies
	 docker build \
		$(DOCKER_BUILD_ARGS) \
			-t bearstech/ruby-dev:2.3 \
			-f Dockerfile.apt-dev \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			.

test-2.3: goss
	@printf "Handling %s\\n" "test-2.3"
	@make -C tests_ruby/test_install_db install tests down RUBY_VERSION=2.3
