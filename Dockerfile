FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# kmod: depmod is required by "make modules_install"
RUN apt-get update && \
    apt-get install -y bc build-essential cpio device-tree-compiler dosfstools \
    expect gawk git kmod libssl-dev parted python python3 qemu-user-static \
    rsync sudo time tzdata udev wget zip

COPY packages .
RUN dpkg -i debootstrap_1.0.87_all.deb live-build_3.0.5-1linaro1_all.deb
RUN apt-get install -f -y
RUN rm debootstrap_1.0.87_all.deb live-build_3.0.5-1linaro1_all.deb
