# Nextflow Package `fastqc`
A simple `fastqc` wrapper written in `nextflow`. The outputs include fastqc output files along with a `qc_metrics.json` which contains some of the important metrics. 

For a bunch of fastq/bam files (Illumina PE or SE), run it with:
```
nextflow run main.nf --seq 'path/to/bam_or_fastq_files'
```

## Package development

The initial version of this package was created by the WorkFlow Package Manager CLI tool, please refer to
the [documentation](https://wfpm.readthedocs.io) for details on the development procedure including
versioning, updating, CI testing and releasing.

## Inputs
### Required
- `seq`: fastq/bam files

### Optional
- `cpus`: cpu number for running the tool
- `mem`: memory (GB) for running the tool
- `publish_dir`: directory for getting the outputs

## Outputs
- `fastqc_results`: fastqc results with pattern `*_fastqc.{zip,html}`
- `fastqc_tar`: a gzip tarball file contains fastqc results and `qc_metrics.json` file

## Example Metrics in `qc_metrics.json`
```
{
  "read_group_id": "C0HVY.2",
  "basic_statistics": "PASS",
  "per_base_sequence_quality": "PASS",
  "per_tile_sequence_quality": "WARN",
  "per_sequence_quality_scores": "PASS",
  "per_base_sequence_content": "FAIL",
  "per_sequence_gc_content": "FAIL",
  "per_base_n_content": "PASS",
  "sequence_length_distribution": "PASS",
  "sequence_duplication_levels": "PASS",
  "overrepresented_sequences": "FAIL",
  "adapter_content": "PASS",
  "file_name": "C0HVY.2_r1.fq.gz",
  "total_sequences": "28",
  "poor_sequences": "0",
  "average_sequence_length": "76",
  "%GC": "65",
  "duplicated_percentage": "100.0"
}

```

## Usage
### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). 
Example params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo-workflows/argo-qc-tools/fastqc/main.nf -r fastqc.v0.2.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the importing package side:

1. add this package's URI `github.com/icgc-argo-workflows/argo-qc-tools/fastqc@0.2.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo-workflows/argo-qc-tools/fastqc@0.2.0/main.nf`
