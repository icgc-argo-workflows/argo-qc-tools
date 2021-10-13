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

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-qc-wg/argo-qc-tools.detin'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = "outdir"  // set to empty string will disable publishDir


// tool specific params go here, add / change as needed
params.mutation_data_path = ""
params.cn_data_path = ""
params.tumor_het_data = ""
params.normal_het_data = ""
params.exac_data_path = ""
params.indel_data_path = ""
params.indel_data_type = "MuTect2"
params.output_name = ""
params.output_pattern = "*.TiN_estimate.txt"  // output file name pattern


process detin {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    file mutation_data_path
    file cn_data_path
    file tumor_het_data
    file normal_het_data
    file exac_data_path
    file indel_data_path
    val indel_data_type
    val output_name

  output:
    path "outdir/${params.output_pattern}", emit: output_file

  script:

    """
    mkdir -p output_dir

    python /tools/deTiN/deTiN.py --mutation_data_path ${mutation_data_path} --cn_data_path ${cn_data_path} --tumor_het_data ${tumor_het_data} --normal_het_data ${normal_het_data} --exac_data_path ${exac_data_path} --output_name ${output_name} --indel_data_path ${indel_data_path} --indel_data_type ${indel_data_type} --output_dir ${params.publish_dir}
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  detin(
    file(params.mutation_data_path)
    file(params.cn_data_path)
    file(params.tumor_het_data)
    file(params.normal_het_data)
    file(params.exac_data_path)
    file(params.indel_data_path)
    params.indel_data_type
    params.output_name
  )
}
