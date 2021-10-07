FROM continuumio/miniconda:4.7.12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

# add ps (required by nextflow)
RUN apt-get --allow-releaseinfo-change update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install requirements for deTiN
RUN /opt/conda/bin/conda install --yes -c conda-forge numpy
RUN /opt/conda/bin/conda install --yes -c conda-forge pandas
RUN /opt/conda/bin/conda install --yes -c conda-forge scipy
RUN /opt/conda/bin/conda install --yes -c conda-forge scikit-learn


# Add main wrapper:
RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"
COPY deTiN /tools/


ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
