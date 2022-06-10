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
/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/
/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'
container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/argo-qc-tools.cutadapt'
]
default_container_registry = 'ghcr.io'
/********************************************************************/
// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""
// tool specific parmas go here, add / change as needed
params.input_file = ""
params.expected_output = ""
include { cutadapt } from '../main'

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  input:
    path output_tgz
    path expected_tgz
  output:
    stdout()

  shell:
    """
    mkdir expected actual
    tar xvf !{output_tgz} -C actual
    tar xvf !{expected_tgz} -C expected

    export NAME=`basename !{output_tgz} .cutadapt.log.qc.tgz`

    diff actual/tar_content.json expected/tar_content.json \
      && ( echo "TAR_CONTENT: Test PASSED" && exit 0 ) || ( echo "TAR_CONTENT: Test FAILED. tar_content.json files do not match" && exit 1 )

    diff actual/\${NAME}.cutadapt.log.qc_metrics.json expected/\${NAME}.cutadapt.log.qc_metrics.json \
      && ( echo "METRICS: Test PASSED" && exit 0 ) || ( echo "METRICS: Test FAILED. \${NAME}.cutadapt.log.qc_metrics.json files do not match" && exit 1 )

    grep -vE "^Command line parameters|^Finished in" actual/\${NAME}.cutadapt.log > actual/cleaned.logfile
    grep -vE "^Command line parameters|^Finished in" expected/\${NAME}.cutadapt.log > expected/cleaned.logfile

    diff actual/cleaned.logfile expected/cleaned.logfile \
      && ( echo "LOGFILE: Test PASSED && exit 0" ) || ( echo "LOGFILE: Log Test FAILED. \${NAME}.cutadapt.log files do not match" && exit 1 )

    """
}
workflow checker {
  take:
    input_R1
    input_R2
    expected_tgz
  main:
    cutadapt(
      file(params.input_R1), file(params.input_R2)
    )
    file_smart_diff(
      cutadapt.out.output_tgz,
      expected_tgz
    )
}
workflow {
  checker(
    file(params.input_R1),
    file(params.input_R2),
    file(params.expected_tgz)
  )
}
