# Use a generic base image that includes build dependencies
FROM buildpack-deps:bullseye

RUN curl -fSsL "https://nodejs.org/dist/v20.17.0/node-v20.17.0-linux-x64.tar.gz" -o /tmp/node.tar.gz && \
  mkdir -p /usr/local/lib/nodejs && \
  tar -xzf /tmp/node.tar.gz -C /usr/local/lib/nodejs --strip-components=1 && \
  rm /tmp/node.tar.gz

ENV PATH /usr/local/lib/nodejs/bin:$PATH
ENV NPM_CONFIG_PREFIX=/usr/local/lib/nodejs
ENV PATH=$PATH:/usr/local/lib/nodejs/bin
ENV NODE_PATH=/usr/local/lib/nodejs/lib/node_modules:$NODE_PATH

RUN npm install -g mongodb-memory-server 
RUN npm install -g mongodb

RUN ln -s /usr/local/lib/nodejs/bin/* /usr/local/bin/

RUN set -xe && \
  apt-get update && \
  apt-get install -y --no-install-recommends locales && \
  rm -rf /var/lib/apt/lists/* && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN set -xe && \
  apt-get update && \
  apt-get install -y --no-install-recommends git libcap-dev && \
  rm -rf /var/lib/apt/lists/* && \
  git clone https://github.com/judge0/isolate.git /tmp/isolate && \
  cd /tmp/isolate && \
  git checkout ad39cc4d0fbb577fb545910095c9da5ef8fc9a1a && \
  make -j$(nproc) install && \
  rm -rf /tmp/*
ENV BOX_ROOT /var/local/lib/isolate

LABEL maintainer="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL version="1.4.0"