RUBY_VERSION:=""

build:
	RUBY_VERSION=${RUBY_VERSION} docker-compose build

down:
	RUBY_VERSION=${RUBY_VERSION} docker-compose down

db:
	RUBY_VERSION=${RUBY_VERSION} docker-compose up -d pg maria

tests: | build down install db
	RUBY_VERSION=${RUBY_VERSION} docker-compose up --exit-code-from client client

install:
	mkdir -p .bundle
	docker run --rm \
		-v `pwd`:/ruby \
		-v `pwd`/.bundle:/.bundle \
		-w /ruby \
		-u `id -u` \
		-e RUBY_VERSION=${RUBY_VERSION} \
		bearstech/ruby-dev:${RUBY_VERSION} \
		./install_db.sh

clean:
	rm -rf vendor
