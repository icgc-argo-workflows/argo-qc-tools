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


def main(input_data, output_dir, interval_file):
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
    if not args.input_data.endswith('.bed') and not args.input_data.endswith('.bam') and not args.input_data.endswith('.gff'):
        sys.exit('Error: Invalid format for input file, need .bed, .gff or .bam!' % args.input_data)

    main(args.input_data, args.output_dir, args.interval_file)
