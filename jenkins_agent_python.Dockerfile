# Use the jenkins inbound-agent image as parent imagine.
FROM jenkins/inbound-agent  
# which is also based on openjdk:8-jdk-stretch, an official docker image

USER root

# install python =====================================================================================
# FROM buildpack-deps:buster-scm
# was already done below

# FROM debian:buster=============================================================================
# https://github.com/docker-library/buildpack-deps/blob/65d69325ad741cea6dee20781c1faaab2e003d87/debian/buster/Dockerfile

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	bzip2 \
	dpkg-dev \
	file \
	g++ \
	gcc \
	imagemagick \
	libbz2-dev \
	libc6-dev \
	libcurl4-openssl-dev \
	libdb-dev \
	libevent-dev \
	libffi-dev \
	libgdbm-dev \
	libglib2.0-dev \
	libgmp-dev \
	libjpeg-dev \
	libkrb5-dev \
	liblzma-dev \
	libmagickcore-dev \
	libmagickwand-dev \
	libmaxminddb-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libpng-dev \
	libpq-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libtool \
	libwebp-dev \
	libxml2-dev \
	libxslt-dev \
	libyaml-dev \
	make \
	patch \
	unzip \
	xz-utils \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

# FROM buildpack-deps:buster-curl
# https://github.com/docker-library/buildpack-deps/blob/65d69325ad741cea6dee20781c1faaab2e003d87/debian/buster/curl/Dockerfile
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	netbase \
	wget \
	&& rm -rf /var/lib/apt/lists/*

RUN if ! command -v gpg > /dev/null; then \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	gnupg \
	dirmngr \
	&& rm -rf /var/lib/apt/lists/*; \
	fi

# FROM buildpack-deps:buster-scm
# https://github.com/docker-library/buildpack-deps/blob/65d69325ad741cea6dee20781c1faaab2e003d87/debian/buster/scm/Dockerfile

#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	#		mercurial \
	#		openssh-client \
	#		subversion \
	\
	procps \
	&& rm -rf /var/lib/apt/lists/*

# FROM buildpack-deps:buster========================================================================
# https://github.com/docker-library/buildpack-deps/blob/65d69325ad741cea6dee20781c1faaab2e003d87/debian/buster/Dockerfile
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
RUN apt-get update; \
	apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	bzip2 \
	dpkg-dev \
	file \
	g++ \
	gcc \
	imagemagick \
	libbz2-dev \
	libc6-dev \
	libcurl4-openssl-dev \
	libdb-dev \
	libevent-dev \
	libffi-dev \
	libgdbm-dev \
	libglib2.0-dev \
	libgmp-dev \
	libjpeg-dev \
	libkrb5-dev \
	liblzma-dev \
	libmagickcore-dev \
	libmagickwand-dev \
	libmaxminddb-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libpng-dev \
	libpq-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libtool \
	libwebp-dev \
	libxml2-dev \
	libxslt-dev \
	libyaml-dev \
	make \
	patch \
	unzip \
	xz-utils \
	zlib1g-dev \
	default-libmysqlclient-dev \
	&& rm -rf /var/lib/apt/lists/*

# =================================
# python/3.9/buster
# Source: https://github.com/docker-library/python/blob/650ac97cef32cd19c6934a517f64c576654d58fe/3.9/buster/Dockerfile
# python 3.9.0 seems to have an issue with pandas: https://github.com/pandas-dev/pandas/issues/36279 
# ==> Using 3.8

# ==================================
# python/3.8/buster
# Source: https://github.com/docker-library/python/blob/650ac97cef32cd19c6934a517f64c576654d58fe/3.8/buster/Dockerfile

#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH
# export PATH=/usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
# export LANG=C.UTF-8

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
	libbluetooth-dev \
	tk-dev \
	uuid-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
# export GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.8.6
# export PYTHON_VERSION=3.8.6


RUN wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
	--build="$gnuArch" \
	--enable-loadable-sqlite-extensions \
	--enable-optimizations \
	--enable-option-checking=fatal \
	--enable-shared \
	--with-system-expat \
	--with-system-ffi \
	--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
	\( \
	\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
	-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
	-o \( -type f -a -name 'wininst-*.exe' \) \
	\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.4
# export PYTHON_PIP_VERSION=20.2.4

# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/8283828b8fd6f1783daf55a765384e6d8d2c5014/get-pip.py
# export PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/8283828b8fd6f1783daf55a765384e6d8d2c5014/get-pip.py
ENV PYTHON_GET_PIP_SHA256 2250ab0a7e70f6fd22b955493f7f5cf1ea53e70b584a84a32573644a045b4bfb
# export PYTHON_GET_PIP_SHA256=2250ab0a7e70f6fd22b955493f7f5cf1ea53e70b584a84a32573644a045b4bfb

RUN wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
	--disable-pip-version-check \
	--no-cache-dir \
	"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
	\( \
	\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
	-o \
	\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
	\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

# CMD ["python3"]

# =install odbc for debian 10/buster======================================================
# see https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 \
	&& apt-get install -y --no-install-recommends unixodbc-dev \
	&& rm -rf /var/lib/apt/lists/*

# =install additional basic python tools====================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
	python-pip \
	&& rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip
RUN pip install --upgrade virtualenv pytest versioneer wheel setuptools tox

# =========================================================================================
# RUN apt-get update && apt-get install -y git-all


USER jenkins
# write date to a file. dynamic information via ARG/ENV does not seem to work.
RUN date > /home/jenkins/image_build
