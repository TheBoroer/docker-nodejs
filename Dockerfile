FROM node:18-alpine3.18

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Install extras
RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && apk update && \
  apk add --no-cache bash \
  openssh-client \
  wget \
  supervisor \
  curl \
  bc \
  gcc \
  musl-dev \
  linux-headers \
  python3 \
  python3-dev \
  py3-pip \
  augeas-dev \
  openssl-dev \
  libffi-dev \
  ca-certificates \
  dialog \
  git \
  make \
  libnetfilter_queue-dev && \
  mkdir -p /var/www/app && \
  mkdir -p /var/log/supervisor

# Alias python/pip to python3/pip3 if it doesnt exist
RUN test -e /usr/bin/python || ln -s /usr/bin/python3 /usr/bin/python 
RUN test -e /usr/bin/pip || ln -s /usr/bin/pip3 /usr/bin/pip

# Install Freebind
RUN mkdir /home/freebind-source && git clone https://github.com/blechschmidt/freebind.git /home/freebind-source/.
RUN cd /home/freebind-source && make install
RUN rm -rf /home/freebind-source

ADD conf/supervisord.conf /etc/supervisord.conf

# Add Scripts
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# copy in code
ADD src/ /app/

# backwards compatibility after webroot change
RUN ln -s /app /var/www/html

RUN mkdir -p /var/log/node/

VOLUME /app/

#CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]
CMD ["/start.sh"]
