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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
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

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.aligned_seq = "" // bam or cram
params.ref_genome = ""  // reference genome: *.[fa|fna|fasta] or *.[fa|fna|fasta].gz, index files: *.fai [*.gzi]
params.target_intervals = ""
params.bait_intervals = ""
params.expected_output = ""

include { picardCollectHsMetrics } from '../main'
include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo/data-processing-utility-tools/helper-functions@1.0.1/main.nf'

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  shell:
    '''
    mkdir output expected

    tar xzf !{output_file} -C output
    tar xzf !{expected_file} -C expected

    cd output
    for f in *; do
      if [ ! -f "../expected/$f" ]
      then
        echo "Test FAILED, found unexpected file: $f in the output tarball" && exit 1
      fi
    done
    cd ..
    
    # three files to check: hs_metrics.json, tar_content.json, test.WES.hs_metrics.txt
    diff output/hs_metrics.json expected/hs_metrics.json && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED for hs_metrics.json, output file mismatch." && exit 1 )
    diff output/tar_content.json expected/tar_content.json && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED for tar_content.json, output file mismatch." && exit 1 )

    # we need to remove the date entry before comparing test.WES.hs_metrics.txt
    grep -v "Started on" output/test.WES.hs_metrics.txt > normalized_output
    grep -v "Started on" expected/test.WES.hs_metrics.txt > normalized_expected
    diff normalized_output normalized_expected && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED for test.WES.hs_metrics.txt, output file mismatch." && exit 1 )
    '''
}


workflow checker {
  take:
    aligned_seq
    ref_genome
    ref_genome_idx
    target_intervals
    bait_intervals
    expected_output

  main:
    picardCollectHsMetrics(
      aligned_seq,
      ref_genome,
      ref_genome_idx,
      target_intervals,
      bait_intervals
    )

    file_smart_diff(
      picardCollectHsMetrics.out.hs_tar,
      expected_output
    )
}


workflow {
  checker(
    file(params.aligned_seq),
    file(params.ref_genome),
    Channel.fromPath(getSecondaryFiles(params.ref_genome, ['fai','gzi']), checkIfExists: false).collect(),
    file(params.target_intervals),
    file(params.bait_intervals),
    file(params.expected_output)
  )
}
