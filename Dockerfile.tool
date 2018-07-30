ARG DEBIAN_DISTRO
FROM bearstech/debian:${DEBIAN_DISTRO}

ENV RUBY_INSTALL_VERSION=0.6.1
WORKDIR /install

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
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
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  wget https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc \
    &&  gpg --import postmodern.asc \
    &&  wget -O ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz \
    &&  wget https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc \
    &&  gpg --verify ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
    &&  tar -xzvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz \
    &&  make -C ruby-install-${RUBY_INSTALL_VERSION}/ install \
    &&  rm -rf  ruby-install-${RUBY_INSTALL_VERSION}/

COPY tool-setup.sh tool-setup.sh
ENTRYPOINT ["sh", "./tool-setup.sh"]
