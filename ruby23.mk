
image-2.3:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby:2.3 \
			-f Dockerfile.apt \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			--build-arg GIT_DATE="${GIT_DATE}" \
			.

image-2.3-dev:
	make -C . ignore_all_rubies
	docker build \
			-t bearstech/ruby-dev:2.3 \
			-f Dockerfile.apt-dev \
			--build-arg DEBIAN_DISTRO=stretch \
			--build-arg RUBY_VERSION=2.3 \
			--build-arg GIT_VERSION=${GIT_VERSION} \
			--build-arg GIT_DATE="${GIT_DATE}" \
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
