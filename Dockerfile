FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Board 2 Debian
# kmod: depmod is required by "make modules_install"
COPY packages /packages

# Install required packages for building Debian
RUN apt-get update
RUN apt-get install -y g++-aarch64-linux-gnu
RUN apt-get update && apt-get install -y git=1:2.25.1-1ubuntu3 ssh make gcc libssl-dev liblz4-tool expect g++ patchelf chrpath gawk texinfo chrpath diffstat binfmt-support qemu-user-static live-build bison flex fakeroot cmake gcc-multilib g++-multilib unzip device-tree-compiler ncurses-dev libgucharmap-2-90-dev bzip2 expat gpgv2 cpp-aarch64-linux-gnu

# kmod: depmod is required by "make modules_install"
RUN apt-get update && apt-get install -y kmod

RUN apt-get update && apt-get install -y zip mtools

# Install additional packages for building base debian system by ubuntu-build-service from linaro
#RUN apt-get install -y binfmt-support qemu-user-static live-build
RUN apt-get install -y bc time rsync zstd python python3 file vim-common sudo
RUN apt-get update && apt-get install -y locales
RUN apt-get update && apt-get install -y bsdmainutils
RUN dpkg -i /packages/* || apt-get install -f -y

RUN locale-gen en_US.UTF-8

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo $username >/root/username

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source
