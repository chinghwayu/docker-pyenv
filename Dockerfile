FROM debian:stretch-slim

LABEL author="Matthew Tardiff <mattrix@gmail.com>"
LABEL maintainer="Brandon LeBlanc <brandon@leblanc.codes>"

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y locales; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8;

ENV LANG="en_US.UTF-8" \
    PYENV_ROOT="/.pyenv" \
    PYENV_GIT_VERSION="7d02b2463b7da53ca62b655c8d5b3a72c7f0cab5" \
    PATH="/.pyenv/bin:/.pyenv/shims:$PATH"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git ca-certificates curl; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

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
# as of Stretch, "gpg" is no longer included by default
        $(command -v gpg > /dev/null || echo 'gnupg dirmngr'); \
    \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

RUN set -eux; \
    git clone "https://github.com/pyenv/pyenv.git" "$PYENV_ROOT"; \
    git --git-dir "$PYENV_ROOT/.git" --work-tree "$PYENV_ROOT" checkout -qf "$PYENV_GIT_VERSION"; \
    rm -rf "$PYENV_ROOT/.git";

ONBUILD COPY python-versions.txt /
ONBUILD RUN set -eux; \
    xargs -P $(nproc) -n 1 pyenv install < python-versions.txt; \
    pyenv global $(pyenv versions --bare); \
    find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rfv '{}' +; \
    find $PYENV_ROOT/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -fv '{}' +; \
    mv -v -- /python-versions.txt $PYENV_ROOT/version;
