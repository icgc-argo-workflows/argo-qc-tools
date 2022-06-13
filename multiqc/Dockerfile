############################################################
# Dockerfile to build Multiqc container images
# Inspiration taken from ghcr.io/ewels/multiqc:latest
# https://github.com/ewels/MultiQC/blob/master/Dockerfile
############################################################

FROM ghcr.io/ewels/multiqc:v1.12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/argo-qc-tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
