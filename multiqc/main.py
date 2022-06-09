#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
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
    Linda Xiang
"""

import os
import sys
import argparse
import subprocess
import json
import tarfile
from glob import glob

def run_cmd(cmd):
    proc = subprocess.Popen(
                cmd,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
    stdout, stderr = proc.communicate()

    return (
        stdout.decode("utf-8").strip(),
        stderr.decode("utf-8").strip(),
        proc.returncode
    )

def get_tool_version(toolname):
    get_tool_version_cmd = f"{toolname} --version | grep -i '^{toolname}'"
    stdout, stderr, returncode = run_cmd(get_tool_version_cmd)
    if returncode:
        sys.exit(f"Error: unable to get version info for {toolname}.\nStdout: {stdout}\nStderr: {stderr}\n")

    return stdout.strip().split(' ')[-1].strip('v')

def prep_qc_metrics(output_dir, tool_ver):
    qc_metrics = {
        'tool': {
            'name': 'MultiQC',
            'version': tool_ver
        },
        'description': 'A single report contains aggregated results from bioinformatics analyses across many samples reported by MultiQC.'
    }

    qc_metrics_file = 'qc_metrics.json'
    with open(qc_metrics_file, "w") as j:
      j.write(json.dumps(qc_metrics, indent=2))

    return qc_metrics_file

def prepare_tarball(qc_metrics, output_dir):

    files_to_tar = [qc_metrics]
    for f in sorted(glob(output_dir+'/*')):
      files_to_tar.append(f)

    tarfile_name = f"multiqc.tgz"
    with tarfile.open(tarfile_name, "w:gz") as tar:
      for f in files_to_tar:
        tar.add(f, arcname=os.path.basename(f))



def main():
    """
    Python implementation of tool: multiqc

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: multiqc')
    parser.add_argument('-i', '--input-file', dest='input_file', type=str, nargs="+",
                        help='Input file', required=True)
    parser.add_argument('-o', '--output-dir', dest='output_dir', type=str,
                        help='Output directory', required=True)
    parser.add_argument('-k', "--data-format", dest="data_format", type=str,
                        help="output data format", default='json')
    parser.add_argument('-x', "--extra-options", dest="extra_options", type=str,
                        help="any extra parameters to pass to multiqc", default='')
    args = parser.parse_args()

    for fn in args.input_file: 
      if not os.path.isfile(fn):
        sys.exit('Error: specified seq file %s does not exist or is not accessible!' % fn)

    # get tool version info
    tool_ver = get_tool_version('multiqc')

    if not os.path.isdir(args.output_dir):
      sys.exit('Error: specified output dir %s does not exist or is not accessible!' % args.output_dir)

    # run multiqc
    multiqc_args = [
        '-f',
        '-o', args.output_dir
    ]

    if args.data_format:
      multiqc_args = multiqc_args + ['-k', args.data_format]

    if args.extra_options:
      multiqc_args = multiqc_args + [args.extra_options]

    cmd = ['multiqc .'] + multiqc_args

    print(cmd)

    stdout, stderr, returncode = run_cmd(" ".join(cmd))
    if returncode:
        sys.exit(f"Error: 'fastqc' failed.\nStdout: {stdout}\nStderr: {stderr}\n")

    # parse multiqc output and put it in qc_metrics.json
    qc_metrics_file = prep_qc_metrics(args.output_dir, tool_ver)

    # prepare tarball to include output files and qc_metrics.json
    prepare_tarball(qc_metrics_file, args.output_dir)

if __name__ == "__main__":
    main()

