FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

COPY poky.tar.gz .
RUN tar zxf poky.tar.gz -C /opt/
RUN rm poky.tar.gz

RUN apt-get update && apt-get install -y gawk wget git=1:2.25.1-1ubuntu3 diffstat unzip \
texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip \
python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full libyaml-dev \
libssl-dev locales sudo

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo $username >/root/username

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source
