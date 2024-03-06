FROM nginx:latest

COPY ./filesystem /.

ARG _SERVER_KEY_PASSPHRASE
ARG _SONARQUBE_ADDRESS
ARG _SONARPROXY_CONTEXT

ENV SONARQUBE_ADDRESS="${_SONARQUBE_ADDRESS}"
ENV SONARPROXY_CONTEXT="${_SONARPROXY_CONTEXT}"

RUN openssl rsa \
  -in /etc/ssl/private/server-encrypted.key \
  -out /etc/ssl/private/server.key \
  -passin "pass:${_SERVER_KEY_PASSPHRASE}"

# RUN openssl dhparam -out /etc/nginx/dhparam.pem 4096

RUN bash /mnt/install-overlay.sh

EXPOSE 80 443
