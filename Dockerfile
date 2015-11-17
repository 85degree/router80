FROM ubuntu:latest
MAINTAINER "Abdul Gaffur A Dama <apung.dama@gmail.com>" #2015-11-17

RUN apt-get update
RUN apt-get install -y build-essential software-properties-common python-software-properties pcre pcre-devel
RUN add-apt-repository ppa:chris-lea/redis-server
RUN apt-get update
RUN apt-get install -y redis-server

ENV OPENRESTY_VERSION 1.9.3.1
ADD ngx_openresty-${OPENRESTY_VERSION}.tar.gz /root/
RUN cd /root/ngx_openresty-* \
 && ./configure --prefix=/opt/openresty --with-http_gunzip_module --with-luajit \
    --with-luajit-xcflags=-DLUAJIT_ENABLE_LUA52COMPAT \
    --http-client-body-temp-path=/var/nginx/client_body_temp \
    --http-proxy-temp-path=/var/nginx/proxy_temp \
    --http-log-path=/var/nginx/access.log \
    --error-log-path=/var/nginx/error.log \
    --pid-path=/var/nginx/nginx.pid \
    --lock-path=/var/nginx/nginx.lock \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-file-aio \
 && make \
 && make install \
 && rm -rf /root/ngx_openresty* \
 && ln -sf /opt/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
 && ln -sf /usr/local/bin/nginx /usr/local/bin/openresty \
 && ln -sf /opt/openresty/bin/resty /usr/local/bin/resty


ADD supervisor /etc/supervisor
ADD redis.conf /etc/redis/

ONBUILD CMD ["supervisord", "-n"]