build-source-2.0: rubies/jessie/ruby-$(RUBY20)

rubies/jessie/ruby-$(RUBY20):
	$(MAKE) tool-jessie
	$(MAKE) rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="jessie"
	docker run --rm \
		--volume `pwd`/rubies/jessie:/opt/rubies \
		ruby-install:jessie $(RUBY20) $(USER)

image-2.0: build-source-2.0
	$(MAKE) rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY20)
	docker build \
			-t bearstech/ruby:2.0 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=jessie \
			--build-arg RUBY_VERSION=$(RUBY20) \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

image-2.0-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.0 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.0 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

test-2.0: tests_ruby/test_install_db/bin/goss
	@printf "Handling %s\\n" "test-2.0"
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_ruby:/goss \
		-w /goss \
		bearstech/ruby-dev:2.0 \
		goss -g ruby-dev.yaml --vars vars/2_0.yaml validate --max-concurrent 4 --format documentation
	@make -C tests_ruby/test_install_db tests down RUBY_VERSION=2.0
