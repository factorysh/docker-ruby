RUBY_VERSION:=""


build:
	RUBY_VERSION=${RUBY_VERSION} docker-compose build

down:
	RUBY_VERSION=${RUBY_VERSION} docker-compose down

db:
	RUBY_VERSION=${RUBY_VERSION} docker-compose up -d pg maria

