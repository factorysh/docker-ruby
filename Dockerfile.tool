ARG debian
FROM bearstech/debian:${debian}

RUN apt-get update && \
    apt-get install -y \
        bison \
        bzip2 \
        build-essential \
        gnupg2 \
        make \
	openssl \
        ruby-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /install
RUN wget https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc && \
        gpg --import postmodern.asc

ENV RUBY_INSTALL_VERSION=0.6.1
RUN wget -O ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz && \
    wget https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc && \
    gpg --verify ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc ruby-install-${RUBY_INSTALL_VERSION}.tar.gz && \
    tar -xzvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz && \
    cd ruby-install-${RUBY_INSTALL_VERSION}/ && \
    make install && \
    cd ../ && \
    rm -rf  ruby-install-${RUBY_INSTALL_VERSION}/
