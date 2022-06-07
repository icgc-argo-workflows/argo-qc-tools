FROM czentye/matplotlib-minimal:3.1.2

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/argo-qc-tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
