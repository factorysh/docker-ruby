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
	docker run --rm \
		-v `pwd`:/ruby \
		-w /ruby \
		-e RUBY_VERSION=${RUBY_VERSION} \
		bearstech/ruby-dev:${RUBY_VERSION} \
		./install_db.sh

clean:
	rm -rf vendor
