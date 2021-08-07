FROM icgc-argo-qc-wg/argo-qc-tools.bedtools-mean

LABEL org.opencontainers.image.source https://github.com/icgc-argo-qc-wg/argo-qc-tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
