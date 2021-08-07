FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get install -y python software-properties-common python3-pip python3-dev curl && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev

# install bedtools 2.30.0
RUN cd /tmp \
    && curl -sSL -o bedtools-2.30.0.tar.gz --retry 10 https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz \
    && tar -xzf bedtools-2.30.0.tar.gz \
    && cd  bedtools2 \
    && make \
    && make install

ENV PATH="/tools:${PATH}"

RUN groupadd -g 1000 ubuntu && \
    useradd -l -u 1000 -g ubuntu ubuntu && \
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

USER ubuntu

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
