# How to get the params.ref_flat.
Parameter `ref_flat` provide the gene annotations in refFlat form. You can download the file from URL:
http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/refFlat.txt.gz

# How to generate the params.ribosomal_interval_list
Parameter `ribosomal_interval_list` provide the locations of rRNA sequences in genome in interval_list format. If not specified no bases will be identified as being ribosomal. You can find more details about the format here: 
https://gatk.broadinstitute.org/hc/en-us/articles/360037057492-CollectRnaSeqMetrics-Picard-#--RIBOSOMAL_INTERVALS

You can use the script `make_rRNA.sh` to generate the `ribosomal_interval_list` file which is suitable for `Picard:CollectRnaSeqMetrics`