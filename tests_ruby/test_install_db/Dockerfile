ARG RUBY_VERSION
FROM bearstech/ruby:${RUBY_VERSION}

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
            libpq5 \
            libmariadbclient18 \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*

