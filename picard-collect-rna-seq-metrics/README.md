# How to get the params.ref_flat.
Param `ref_flat` provide the gene annotations in refFlat form. You can download the file from [URL](http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/refFlat.txt.gz)


# How to generate the params.ribosomal_interval_list
Param `ribosomal_interval_list` provide the locations of rRNA sequences in genome in interval_list format. If not specified no bases will be identified as being ribosomal. You can find more details about the format [here](https://gatk.broadinstitute.org/hc/en-us/articles/360037057492-CollectRnaSeqMetrics-Picard-#--RIBOSOMAL_INTERVALS)


You can use the provided script [`make_rRNA.sh`](./make_rRNA.sh) to generate the `ribosomal_interval_list` file which is suitable for `Picard:CollectRnaSeqMetrics`

# How to run the testing jobs
In order to run the testing jobs successfully, you will need to 
- Have `root` or `sudo` privileges of the machine
- Have `docker` installed and been up running

You can following the steps to do the testing
```
cd tests
nextflow run checker.nf -params-file test-job-1.json
nextflow run checker.nf -params-file test-job-2.json
```

# How to get the output files
You can specify the param `publish_dir` to a folder like `myout`, 
```
nextflow run checker.nf -params-file test-job-1.json --publish_dir myout
```
You will find the output files under the given folder. E.g.,
```
myout
└── checker_picardCollectRnaSeqMetrics
    └── sample_01_L1_Aligned.out.bam.collectrnaseqmetrics.tgz
```