FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

COPY packages /packages

# Install required packages for building Tinker Edge R Debian
# kmod: depmod is required by "make modules_install"
RUN apt-get update && \
    apt-get install -y make gcc bc python libssl-dev liblz4-tool sudo time \
    g++ patch wget cpio unzip rsync bzip2 perl gcc-multilib git kmod parted \
    gdisk udev expect gawk zip

# Install required package for building Tinker Edge R base Debian system
RUN  apt-get update && \
     apt-get install -y binfmt-support qemu-user-static live-build
RUN dpkg -i /packages/* || apt-get install -f -y

RUN apt-get install -y fakeroot

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
