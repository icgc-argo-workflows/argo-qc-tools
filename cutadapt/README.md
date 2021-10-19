# Cutadapt Quality Control workflow

This tool runs Cutadapt for the sole purpose of extracting information about
adapter contamination. It does not output the trimmed FASTQs by default.

## Prerequisites

* Nextflow, tested on 21.04.1
* Docker, tested on V 3.5.1

## Supported platforms

Because this runs in a Docker container, any Linux or Linux-like environment is
sufficient.

## Running

With parameters on the command line:
```
nextflow run main.nf --input_R1 tests/input/TCRBOA7-T-RNA.250reads.read1.fastq.gz --input_R2 tests/input/TCRBOA7-T-RNA.250reads.read2.fastq.gz --publish_dir testmyoutput
```

With a parameter file:

```
nextflow run main.nf -params-file params.json
```

## Input parameters

**Required**:

* `input_R1`: Read1 fastq file. This is assumed to be in a gzipped form.
* `input_R2`: Read2 fastq file. This is assumed to be in a gzipped form.
* `publish_dir`: the final location for the results.

**Optional**:

* `read1_adapter` : Override the adapter for read 1. Default: "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
* `read2_adapter` : Override the adapter for read 2. Default: "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
* `min_length` : set the minimum length permitted for reads. Default: 1
* `qual_cutoff`: set the minimum permitted quality for bases. Default: 0
* `extra_options` : any other options to pass to Cutadapt directly
* `cpus` : Default: 1
* `mem` : Default: 1

## Output results

Produces a tarred, gzipped file with exactly 3 files, where `$NAME` is the first
token of the fastq filename, before any `.`.

* `tar_content.json` : JSON file containing the locations of the other two files
  in the archive
* `$NAME.cutadapt.log.qc_metrics.json` : JSON file containing metrics extracted
  from the Cutadapt log
* `$NAME.cutadapt.log` : Plain text file containing the standard out from
  running Cutadapt

Examples of these files are located in [tests/expected](tests/expected).

### Metrics

Current metrics captured in the qc_metrics file include:
* `adapter_read1_percent `: the percent of read 1's that contained adapter sequence.
* `adapter_read2_percent`: the percent of read 2's that contained adapter sequence.
* `quality_trimmed_percent`: the percent of reads that were trimmed for quality.
  By default, this should be 0, because by default, quality trimming is turned off.


## Local Testing

Install [WFPM](https://github.com/icgc-argo/wfpm).

1. Clone the repository
2. Switch to the correct project with WFPM
```
wfpm workon cutadapt
```
3. Build the Docker container locally
```
cd cutadapt
docker build -t ghcr.io/icgc-argo-qc-wg/argo-qc-tools.cutadapt:3.4.0 .
```
4. Run the tests
```
wfpm test
```

If everything works correctly, you should see something like the following:
```
% wfpm test
Validating package: /Users/mtaschuk/git/argo-qc-tools/cutadapt
Pakcage valid.
Testing package: /Users/mtaschuk/git/argo-qc-tools/cutadapt
[1/1] Testing: /Users/mtaschuk/git/argo-qc-tools/cutadapt/tests/test-job-1.json. PASSED
Tested package: cutadapt, PASSED: 1, FAILED: 0
```
