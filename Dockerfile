#
#  Docker build and run
#
#  Alex Shvid
#

FROM ubuntu:18.04

LABEL maintainer "Alex Shvid <a@shvid.com>"

ENV DEBIAN_FRONTEND noninteractive

# Prerequisite and locale
RUN apt-get update &&\
    apt-get autoclean &&\
    apt-get install -y ca-certificates && \
    apt-get -y install locales python3 python3-pip git wget nano fish mc lib32stdc++6 tzdata && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV REQUESTS_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt
ENV LANG en_US.UTF-8

# pip and setuptools
RUN pip3 install --upgrade pip --trusted-host pypi.org --trusted-host files.pythonhosted.org && \
    pip install --upgrade setuptools wheel --trusted-host pypi.org --trusted-host files.pythonhosted.org

# security and SSL
RUN pip install -U cryptography requests[security] --no-cache --trusted-host pypi.org --trusted-host files.pythonhosted.org

# setup PDT timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && echo "America/Los_Angeles" > /etc/timezone

# Install rocksdb
RUN apt-get -y install build-essential iotop zip libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev liblz4-dev libzstd-dev && \
    git clone https://github.com/facebook/rocksdb.git && \
    cd rocksdb && \
    git checkout tags/v6.14.6 && \
    make shared_lib && \
    mv /rocksdb/include/rocksdb /usr/include/ && \
    mv /rocksdb/librocksdb.so.* /usr/lib/ && \
    ln -s /usr/lib/librocksdb.so.6 /usr/lib/librocksdb.so && \
    cd / && rm -rf /rocksdb

# Install python-rocksdb
RUN pip3 install python-rocksdb --trusted-host pypi.org --trusted-host files.pythonhosted.org
