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
    Andrej Benjak
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0.1'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/argo-qc-tools.picard-collect-hs-metrics'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 4  // GB
params.publish_dir = ""  // set to empty string will disable publishDir
params.help = null


// tool specific parmas go here, add / change as needed
params.aligned_seq = "" // bam or cram
params.ref_genome = ""  // reference genome: *.[fa|fna|fasta] or *.[fa|fna|fasta].gz, index files: *.fai [*.gzi]
params.target_intervals = ""
params.bait_intervals = ""


def helpMessage() {
    log.info"""
picard-collect-hs-metrics

USAGE

Mandatory arguments:
    --aligned_seq       Input alignments, can be bam or cram.
    --ref_genome        Reference genome (uncompressed or bgzipped fasta file): *.[fa|fna|fasta] or *.[fa|fna|fasta].gz
                        The *.fai index must be available, as well as the *.gzi in case of a compressed fasta file.
    --target_intervals  Targets file in interval format (dictionary header + bed).
                        These are usually named as 'covered' files by the capture-kit provider.
    --bait_intervals    Baits file in interval format (dictionary header + bed).
                        These are usually named as 'padded' files by the capture-kit provider.
                        If not available, provide the targets file here as well.
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()

// Validate inputs
if(params.aligned_seq == "") error "Missing mandatory '--aligned_seq'"
if(params.ref_genome == "") error "Missing mandatory '--ref_genome'"
if(params.target_intervals == "") error "Missing mandatory '--target_intervals'"
if(params.bait_intervals == "") error "Missing mandatory '--bait_intervals'"

log.info ""
log.info "input file: ${params.aligned_seq}"
log.info "reference genome file: ${params.ref_genome}"
log.info "targets file: ${params.target_intervals}"
log.info "baits file: ${params.bait_intervals}"
log.info ""


include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo/data-processing-utility-tools/helper-functions@1.0.1/main.nf'

process picardCollectHsMetrics {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path aligned_seq
    path ref_genome
    path ref_genome_idx
    path target_intervals
    path bait_intervals

  output:
    path "*.hs_metrics.tgz", emit: hs_tar

  shell:
    '''
    main.sh -i !{aligned_seq} -r !{ref_genome} -t !{target_intervals} -b !{bait_intervals}
    '''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  picardCollectHsMetrics(
    file(params.aligned_seq),
    file(params.ref_genome),
    Channel.fromPath(getSecondaryFiles(params.ref_genome, ['fai','gzi']), checkIfExists: false).collect(),
    file(params.target_intervals),
    file(params.bait_intervals)
  )
}
