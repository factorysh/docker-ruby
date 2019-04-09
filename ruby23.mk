
build-source-2.3-jessie: rubies/jessie/ruby-$(RUBY23)

rubies/jessie/ruby-$(RUBY23):
	make -C . tool-jessie
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DEPTH="1" DOCKER_IGNORE_RUBIES_DIR_REV="jessie"
	docker run --rm \
		--volume `pwd`/rubies/jessie:/opt/rubies \
		ruby-install:jessie 2.3 $(USER)

image-2.3:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby:2.3 \
			-f Dockerfile.apt \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

image-2.3-jessie: build-source-2.3-jessie
	make -C . rubies_docker_ignore DOCKER_IGNORE_RUBIES_DIR_REV=$(RUBY23)
	docker build \
			-t bearstech/ruby:2.3-jessie \
			-f Dockerfile.ruby-install \
			--build-arg DEBIAN_DISTRO=jessie \
			--build-arg RUBY_VERSION=$(RUBY23) \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

image-2.3-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.3 \
			-f Dockerfile.apt-dev \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

image-2.3-jessie-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.3-jessie \
			-f Dockerfile.ruby-install-dev \
			--build-arg RUBY_FROM_TAG=2.3-jessie \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			.

test-2.3: tests_ruby/test_install_db/bin/goss
	@printf "Handling %s\\n" "test-2.3"
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_ruby:/goss \
		-w /goss \
		bearstech/ruby-dev:2.3 \
		goss -g ruby-dev.yaml --vars vars/2_3.yaml validate --max-concurrent 4 --format documentation
	@make -C tests_ruby/test_install_db tests down RUBY_VERSION=2.3

test-2.3-jessie: bin/goss
	@printf "Handling %s\\n" "test-2.3-jessie"
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_ruby:/goss \
		-w /goss \
		bearstech/ruby-dev:2.3-jessie \
		goss -g ruby-dev.yaml --vars vars/2_3.yaml validate --max-concurrent 4 --format documentation

