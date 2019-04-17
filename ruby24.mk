build-source-2.4: rubies/stretch/ruby-$(RUBY24)

rubies/stretch/ruby-$(RUBY24):
	make -C . tool-stretch
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="stretch"
	docker run --rm \
		--volume `pwd`/rubies/stretch:/opt/rubies \
		ruby-install:stretch $(RUBY24) $(USER)

image-2.4: build-source-2.4
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY24)
	docker build \
			-t bearstech/ruby:2.4 \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=$(RUBY24) \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			--build-arg GIT_DATE="${GIT_DATE}" \
			.

image-2.4-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.4 \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.4 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			--build-arg GIT_DATE="${GIT_DATE}" \
			.

test-2.4: tests_ruby/test_install_db/bin/goss
	@printf "Handling %s\\n" "test-2.4"
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_ruby:/goss \
		-w /goss \
		bearstech/ruby-dev:2.4 \
		goss -g ruby-dev.yaml --vars vars/2_4.yaml validate --max-concurrent 4 --format documentation
	@make -C tests_ruby/test_install_db tests down RUBY_VERSION=2.4
