ARG DEBIAN_DISTRO
FROM bearstech/debian:${DEBIAN_DISTRO}

ARG RUBY_INSTALL_VERSION
ARG DEBIAN_DISTRO

ENV RUBY_INSTALL_VERSION=${RUBY_INSTALL_VERSION}

WORKDIR /install

RUN set -eux \
    &&  export http_proxy=${HTTP_PROXY} \
    &&  apt-get update \
    &&  if [ "${DEBIAN_DISTRO}" = "stretch" ]; then apt-get install -y --no-install-recommends \
                      bison \
                      bzip2 \
                      build-essential \
                      ca-certificates \
                      git \
                      gnupg2 \
                      libffi-dev \
                      libgdbm3 \
                      libgdbm-dev \
                      libncurses5-dev \
                      libreadline6-dev \
                      libssl-dev \
                      libyaml-dev \
                      make \
                      openssl \
                      ruby-dev \
                      wget \
                      zlib1g-dev \
	; fi \
    &&  if [ "${DEBIAN_DISTRO}" = "buster" ]; then apt-get install -y --no-install-recommends \
                      bison \
                      bzip2 \
                      build-essential \
                      ca-certificates \
                      git \
                      gnupg2 \
                      libffi-dev \
                      libgdbm6 \
                      libgdbm-dev \
                      libncurses5-dev \
                      libreadline6-dev \
                      libssl-dev \
                      libyaml-dev \
                      make \
                      openssl \
                      ruby-dev \
                      wget \
                      zlib1g-dev \
	; fi \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  wget -q https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc \
    &&  gpg --import postmodern.asc \
    &&  wget -qO ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz \
    &&  wget -q https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc \
    &&  gpg --verify ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
    &&  tar -xzvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
    &&  make -C ruby-install-${RUBY_INSTALL_VERSION}/ install \
    &&  rm -rf  ruby-install-${RUBY_INSTALL_VERSION}/

COPY tool-setup.sh tool-setup.sh
ENTRYPOINT ["sh", "./tool-setup.sh"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL com.bearstech.image.revision_date=${GIT_DATE}

LABEL org.opencontainers.image.authors=Bearstech

LABEL org.opencontainers.image.revision=${GIT_VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}

LABEL org.opencontainers.image.url=https://github.com/factorysh/docker-ruby
LABEL org.opencontainers.image.source=https://github.com/factorysh/docker-ruby/blob/${GIT_VERSION}/Dockerfile.tool
