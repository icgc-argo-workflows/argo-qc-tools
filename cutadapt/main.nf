#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC ARGO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Morgan Taschuk
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.1'  // package version, changed from 3.4.0 so it doesnt match cutadapt

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/argo-qc-tools.cutadapt'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific params go here, add / change as needed
params.input_R1=""
params.input_R2=""
params.output_pattern = "*.cutadapt.log.qc.tgz"  // output file name pattern
params.read1_adapter="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
params.read2_adapter="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
params.min_length=1
params.qual_cutoff=0
params.extra_options=""

process cutadapt {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path input_R1
    path input_R2

  output:
    path "output_dir/${params.output_pattern}", emit: output_tgz

  script:
    // add and initialize variables here as needed

    """
    mkdir -p output_dir

    main.py \
      -1 ${input_R1} -2 ${input_R2} \
      -o output_dir \
      -a ${params.read1_adapter} \
      -A ${params.read2_adapter} \
      -m ${params.min_length} \
      -q ${params.qual_cutoff} ${params.extra_options}
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run icgc-argo-workflows/argo-qc-tools/cutadapt/main.nf -r cutadapt.v3.4.0 --params-file
workflow {
  cutadapt(
    file(params.input_R1),
    file(params.input_R2)
  )
}
