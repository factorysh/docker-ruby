
image-2.1:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby:2.1 \
			-f Dockerfile.apt \
			--build-arg DEBIAN_DISTRO=jessie \
			--build-arg RUBY_VERSION=2.1 \
			.

image-2.1-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.1 \
			-f Dockerfile.apt-dev \
			--build-arg DEBIAN_DISTRO=jessie \
			--build-arg RUBY_VERSION=2.1 \
			.

test-2.1: tests_ruby/test_install_db/bin/goss
	@printf "Handling %s\\n" "test-2.1"
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_ruby:/goss \
		-w /goss \
		bearstech/ruby-dev:2.1 \
		goss -g ruby-dev.yaml --vars vars/2_1.yaml validate --max-concurrent 4 --format documentation
	@make -C tests_ruby/test_install_db tests down RUBY_VERSION=2.1

