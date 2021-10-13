FROM continuumio/miniconda:4.7.12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

# add ps (required by nextflow)
RUN apt-get --allow-releaseinfo-change update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Add main wrapper:
RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"
COPY deTiN /tools/

# install requirements for deTiN
CMD ["/tools/deTiN/setup.py install"]
ENTRYPOINT ["python"]


ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
