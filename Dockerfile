FROM debian:buster-slim

LABEL author="Matthew Tardiff <mattrix@gmail.com>"
LABEL maintainer="Brandon LeBlanc <brandon@leblanc.codes>"

ENV DEBIAN_FRONTEND noninteractive

# Use en_US.UTF-8 locale
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y locales; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8;
ENV LANG=en_US.UTF-8

# Install gosu to de-elevate permissions
# https://github.com/tianon/gosu#from-debian
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y gosu; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# install git and curl
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git ca-certificates curl; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# install python dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        dpkg-dev \
        gcc \
        libbz2-dev \
        libc6-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libyaml-dev \
        make \
        netbase \
        tk-dev \
        uuid-dev \
        wget \
        xz-utils \
        zlib1g-dev \
        $(command -v gpg > /dev/null || echo 'gnupg dirmngr'); \
    \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# configure pyenv
ENV PYENV_ROOT="/.pyenv" \
    PYENV_GIT_VERSION="174b7e72a1e11f22a1231f1576e96ab771b16766" \
    PATH="/.pyenv/bin:/.pyenv/shims:$PATH"

# clone and install pyenv
RUN set -eux; \
    git clone "https://github.com/pyenv/pyenv.git" "$PYENV_ROOT"; \
    git --git-dir "$PYENV_ROOT/.git" --work-tree "$PYENV_ROOT" checkout -qf "$PYENV_GIT_VERSION"; \
    rm -rf "$PYENV_ROOT/.git";

# these actions are executed before building sub-images
# copies a local `python-versions.txt` file
ONBUILD COPY python-versions.txt /
# and installs the included python versions
ONBUILD RUN set -eux; \
    xargs -P$(nproc) -n 1 pyenv install < python-versions.txt; \
    mv -v -- /python-versions.txt $PYENV_ROOT/version; \
    pyenv rehash; \
    pyenv versions; \
    find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rf '{}' +; \
    find $PYENV_ROOT/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -f '{}' +;
