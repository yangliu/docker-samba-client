# docker-samba-client
# 
# VERSION 0.0.1

FROM debian:jessie
MAINTAINER Yang Liu <i@yangliu.name>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -yqq cifs-utils inotify-tools

ADD smb-client.sh /usr/local/bin/smb-client
ENTRYPOINT ["/usr/local/bin/smb-client"]
