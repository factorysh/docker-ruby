ARG RUBY_VERSION
FROM bearstech/ruby:${RUBY_VERSION}

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
            libpq5 \
            lsb-release \
    && if [ "$(lsb_release -cs)" = "buster" ]; then \
         apt-get install -y --no-install-recommends \
            libmariadb3 \
       ; fi \
    && if [ "$(lsb_release -cs)" = "stretch" ]; then \
         apt-get install -y --no-install-recommends \
            libmariadbclient18 \
       ; fi \
    && if [ "$(lsb_release -cs)" = "jessie" ]; then \
         apt-get install -y --no-install-recommends \
            libmysqlclient18 \
       ; fi \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*

