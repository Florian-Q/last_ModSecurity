FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

ENV PATH_MODSEC_EXTRACT /modsecurity

WORKDIR /tmp/modsecurity

RUN OFFICIAL_DEPO="https://github.com/SpiderLabs/ModSecurity.git" \
	&& apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates 	 \
		automake             \
		autoconf             \
		build-essential      \
		libcurl4-openssl-dev \
		libpcre++-dev        \
		libtool              \
		libxml2-dev          \
		libyajl-dev          \
		lua5.2-dev           \
		git                  \
		pkgconf              \
		ssdeep               \
		libgeoip-dev         \
	    curl 				 \
	    tar 				 \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* \
	# get last number version of tag "refs/tags/vX.X.X"
	&& LAST_VERSION=$(git ls-remote --tags $OFFICIAL_DEPO | \
		grep -o '[0-9]\+\.[0-9]\+\.[0-9]$' | \
		sort -n | tail -1 ) \
	&& echo "the last version of ModSecurity is : $LAST_VERSION" \
	# Download and extract
	&& curl -s https://codeload.github.com/SpiderLabs/ModSecurity/tar.gz/v${LAST_VERSION} --output modsec.tar.gz \
	&& tar -zxf modsec.tar.gz \
	&& mv "ModSecurity-$LAST_VERSION" $PATH_MODSEC_EXTRACT \
	# compile 
	&& cd $PATH_MODSEC_EXTRACT \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \
    && make \
    && make install \
    && strip /usr/local/modsecurity/bin/* /usr/local/modsecurity/lib/*.a /usr/local/modsecurity/lib/*.so*