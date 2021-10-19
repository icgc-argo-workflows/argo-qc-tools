############################################################
# Dockerfile to build Cutadapt container images
# Inspiration taken from genomicpariscentre/cutadapt:2.10
# https://github.com/GenomicParisCentre/dockerfiles/blob/master/cutadapt/2.10/Dockerfile
############################################################

# Set the base image to Ubuntu
FROM ubuntu:20.04

ARG PACKAGE_VERSION=2.10
ARG BUILD_PACKAGES="build-essential"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install --yes $BUILD_PACKAGES && \
    apt install --yes python3-pip \
                      libpython3-dev && \
    pip3 install "cutadapt==$PACKAGE_VERSION" && \
    apt autoremove --purge --yes && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/argo-qc-tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
