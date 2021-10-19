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
    Raquel Manzano
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
    'ghcr.io': 'ghcr.io/icgc-argo-qc-wg/argo-qc-tools.detin'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.mutation_data_path = ""
params.cn_data_path = ""
params.tumor_het_data = ""
params.normal_het_data = ""
params.exac_data_path = ""
params.indel_data_path = ""
params.indel_data_type = ""
params.output_name = ""
params.expected_output = ""

include { detin } from '../main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_path
    path expected_file

  output:
    stdout()

  script:
    """
    cut -f1-6 ${output_path}/*.txt | sort  > ${output_path}/output_cat.txt
    diff  ${output_path}/output_cat.txt ${expected_file} \
      && ( echo 'Test PASSED' && exit 0 ) || ( echo 'Test FAILED, output file mismatch.' && exit 1 )
    """
}


workflow checker {
  take:
    mutation_data_path
    cn_data_path
    tumor_het_data
    normal_het_data
    exac_data_path
    indel_data_path
    indel_data_type
    output_name
    expected_file

  main:
    detin(
      mutation_data_path,
      cn_data_path,
      tumor_het_data,
      normal_het_data,
      exac_data_path,
      indel_data_path,
      indel_data_type,
      output_name
    )

    file_smart_diff(
      detin.out.output_path,
      expected_file
    )
}


workflow {
  checker(
    file(params.mutation_data_path),
    file(params.cn_data_path),
    file(params.tumor_het_data),
    file(params.normal_het_data),
    file(params.exac_data_path),
    file(params.indel_data_path),
    params.indel_data_type,
    params.output_name,
    file(params.expected_file)
  )
}
