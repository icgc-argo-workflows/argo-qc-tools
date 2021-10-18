FROM continuumio/miniconda3:4.9.2

LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

# add ps (required by nextflow)
RUN apt-get --allow-releaseinfo-change update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Add main wrapper:
COPY deTiN /tools/deTiN

ENV PATH="/tools:${PATH}"
# install requirements for deTiN

RUN python /tools/deTiN/setup.py install

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
