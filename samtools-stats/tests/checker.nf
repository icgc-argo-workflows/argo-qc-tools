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
    Junjun Zhang
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
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/argo-qc-tools.samtools-stats'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.aligned_seq = ""
params.ref_genome_gz = ""  // reference genome: *.fa.gz, index file: *.fa.gz.fai
params.expected_output = ""

include { samtoolsStats } from '../main'
include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo/data-processing-utility-tools/helper-functions@1.0.1/main.nf'

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    mkdir output expected

    tar xzf ${output_file} -C output
    tar xzf ${expected_file} -C expected

    cd output
    for f in *; do
      if [ ! -f "../expected/\$f" ]
      then
        echo "Test FAILED, found unexpected file: \$f in the output tarball" && exit 1
      fi

      echo diff \$f ../expected/\$f
      # we ignore diff from the lines with 'The command line' since they contain dynamic file path
      EFFECTIVE_DIFF=`diff \$f ../expected/\$f | egrep '<|>' | grep -v ' # The command line was:' || true`

      if [ ! -z "\$EFFECTIVE_DIFF" ]
      then
        echo -e "Test FAILED, output file \$f mismatch:\n\$EFFECTIVE_DIFF" && exit 1
      fi
    done

    echo "All files match, test PASSED" && exit 0
    """
}


workflow checker {
  take:
    aligned_seq
    ref_genome_gz
    ref_genome_gz_idx
    expected_output

  main:
    samtoolsStats(
      aligned_seq,
      ref_genome_gz,
      ref_genome_gz_idx
    )

    file_smart_diff(
      samtoolsStats.out.qc_tar,
      expected_output
    )
}


workflow {
  checker(
    file(params.aligned_seq),
    file(params.ref_genome_gz),
    Channel.fromPath(
      getSecondaryFiles(params.ref_genome_gz, ['fai']), checkIfExists: true
    ).collect(),
    file(params.expected_output)
  )
}
