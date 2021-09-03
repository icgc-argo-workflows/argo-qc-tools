FROM continuumio/miniconda3:4.9.2

# filled by wfpm
LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

# add ps (required by nextflow)
RUN apt-get -y update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="//opt/conda/bin:${PATH}"

# install java
RUN conda install --yes -c conda-forge openjdk=11.0.9.1

# Fetch Picard
RUN wget https://github.com/broadinstitute/picard/releases/download/2.25.7/picard.jar

# add main.sh to /tools
RUN mkdir /tools
COPY main.sh /tools/
ENV PATH="/tools:${PATH}"


ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
