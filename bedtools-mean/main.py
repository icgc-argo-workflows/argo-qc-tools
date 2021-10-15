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
    Peter Ruzanov
"""

import os
import sys
import argparse
import subprocess
import json
import tarfile


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


def get_tool_version():
    """
    Get version of the bedtools
    """
    get_tool_version_cmd = "bedtools --version | grep -i '^bedtools'"
    stdout, stderr, returncode = run_cmd(get_tool_version_cmd)
    if returncode:
        sys.exit(f"Error: unable to get version info for bedtools.\nStdout: {stdout}\nStderr: {stderr}\n")

    return stdout.strip().split(' ')[-1]


def prep_qc_metrics(coverage_mean, tool_ver):
    intervals = 0
    coverage = 0
    covered_intervals = 0
    max_coverage = 0
    with open(coverage_mean, 'r') as f:
        for row in f:
            cols = row.strip().split('\t')
            current_coverage = float(cols[-1])
            intervals += 1
            if current_coverage != 0:
                covered_intervals += 1
                coverage += current_coverage
                max_coverage = current_coverage if max_coverage < current_coverage else max_coverage

    json_rows = [{"intervals_covered": covered_intervals},
                 {"mean_coverage": round(coverage / intervals, 3)},
                 {"max_coverage": max_coverage}]

    qc_metrics = {
        'tool': {
            'name': 'Bedtools:coverage_mean',
            'version': tool_ver.strip('v')
        },
        'metrics': json_rows
    }

    qc_metrics_file = 'qc_metrics.json'
    with open(qc_metrics_file, "w") as j:
        j.write(json.dumps(qc_metrics, indent=2))

    return qc_metrics_file


def prepare_tarball(input_data, qc_metrics, mean_coverage):
    tar_content = {
        'qc_metrics': qc_metrics,
        'mean_coverage': mean_coverage
    }

    with open('tar_content.json', 'w') as t:
        t.write(json.dumps(tar_content, indent=2))

    files_to_tar = ['tar_content.json', qc_metrics, mean_coverage]

    tarfile_name = f"{os.path.basename(input_data)}.coverage_mean.tgz"
    with tarfile.open(tarfile_name, "w:gz") as tar:
        for f in files_to_tar:
            tar.add(f, arcname=os.path.basename(f))


def main(input_data, interval_file, output_dir):
    """
    Python implementation of tool: bedtools (coverageBed) with mean option

    This is auto-generated Python code, please update as needed!
    """
    tool_ver = get_tool_version()

    input_args = [
        '-a', interval_file,
        '-b', input_data,
        '-mean'
    ]
    suffix = ".coverage_mean.tsv"
    output_file = input_data + suffix

    if output_dir.endswith("/"):
        output_file = "".join([output_dir, input_data]) + suffix
    else:
        "/".join([output_dir, input_data]) + suffix

    cmd = ['bedtools', 'coverage'] + input_args + [">", output_file]
    print("Running bedtools " + tool_ver)
    stdout, stderr, returncode = run_cmd(" ".join(cmd))
    if returncode:
        sys.exit(f"Error: 'bedtools coverage' failed.\nStdout: {stdout}\nStderr: {stderr}\n")

    # parse bedtools output and put it in qc_metrics.json
    qc_metrics_file = prep_qc_metrics(output_file, tool_ver)

    # prepare tarball to include output files and qc_metrics.json
    prepare_tarball(input_data, qc_metrics_file, output_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Tool: bedtools')
    parser.add_argument('-d', '--input-data', dest='input_data', type=str,
                        help='Input file (.bam,.bed,.gff)', required=True)
    parser.add_argument('-i', '--interval-file', dest='interval_file', type=str,
                        help='Optional interval file (.bed)', required=False)
    parser.add_argument('-o', '--output-directory', dest='output_dir', type=str,
                        help='Output Directory', required=False)
    args = parser.parse_args()

    if args.output_dir is None:
        args.output_dir = "./"
    if args.interval_file is None:
        sys.exit('Error: interval file is needed!')

    if not os.path.isfile(args.input_data):
        sys.exit('Error: specified input file %s does not exist or is not accessible!' % args.input_data)
    if args.interval_file is not None and not os.path.isfile(args.interval_file):
        sys.exit('Error: no valid interval file specified!')
    if not os.path.isdir(args.output_dir):
        sys.exit('Error: specified output dir %s does not exist or is not accessible!' % args.output_dir)
    if not args.input_data.endswith('.bed') and not args.input_data.endswith('.bam') \
            and not args.input_data.endswith('.gff') \
            and not args.input_data.endswith('.cram'):
        sys.exit('Error: Invalid format for input file, need .bed, .gff, .cram or .bam!' % args.input_data)

    main(args.input_data, args.interval_file, args.output_dir)
