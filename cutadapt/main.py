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
    Morgan Taschuk
"""

import os
import sys
import argparse
import subprocess
import re
import json
import tarfile
import hashlib

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

def prepare_tarball(qc_metrics, logfile):
    tar_content = {
        'qc_metrics': os.path.basename(qc_metrics),
        'cutadapt_log': os.path.basename(logfile)
    }

    with open('tar_content.json', 'w') as t:
        t.write(json.dumps(tar_content, indent=2))

    files_to_tar = ['tar_content.json', qc_metrics, logfile]

    tarfile_name = re.sub(r'.log$', r'.tgz', logfile)
    with tarfile.open(tarfile_name, "w:gz") as tar:
        for f in files_to_tar:
            tar.add(f, arcname=os.path.basename(f))

def get_tool_version():
    get_tool_version_cmd = "cutadapt --version"
    stdout, stderr, returncode = run_cmd(get_tool_version_cmd)
    if returncode:
        sys.exit(f"Error: unable to get version info for samtools.\nStdout: {stdout}\nStderr: {stderr}\n")

    return stdout.strip()

def prep_qc_metrics(cutadapt_log, tool_ver):
    qc_metrics = {
        'tool': {
            'name': 'Cutadapt',
            'version': tool_ver
        },
        'metrics': {}
    }

    with open(cutadapt_log,'r') as l:
        log=l.read()
        adapt=re.search("Read 1 with adapter:\s+\d+.+(\d+\.\d+)%",log)
        if adapt is None:
            adapt=re.search("Reads with adapters:\s+\d+.+(\d+\.\d+)%",log)
    qc_metrics['metrics']['adapter_percent']=float(adapt.group(1))

    qc_metrics_file = f"{os.path.dirname(cutadapt_log)}/{os.path.basename(cutadapt_log)}.qc_metrics.json"
    with open(qc_metrics_file, "w") as j:
        j.write(json.dumps(qc_metrics, indent=2))

    return qc_metrics_file


def main():
    """
    Python implementation of tool: cutadapt

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: cutadapt')
    parser.add_argument('-1', '--input-R1', dest='input_R1', type=str,
                        help='Input file read 1', required=True)
    parser.add_argument('-2', '--input-R2', dest='input_R2', type=str,
                        help='Input file read 2')
    parser.add_argument('-r', '--rg_id', dest='rg_id', type=str,
                        help='Read group ID', required=True)
    parser.add_argument('-o', '--output-dir', dest='output_dir', type=str,
                        help='Output directory', required=True)
    parser.add_argument('-a', '--read1-adapter', dest='adapter_R1', type=str,
                        help='Sequence of an adapter ligated to the 3\' end (paired data: of the first read). The adapter and subsequent bases are trimmed. If a \'$\' character is appended (\'anchoring\'), the adapter is only found if it is a suffix of the read.',
                        default='AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC')
    parser.add_argument('-A', '--read2-adapter', dest='adapter_R2', type=str,
                        help='3\' adapter to be removed from second read in a pair.',
                        default='AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT')
    parser.add_argument('-m', '--minimum-length', dest="min_trim_len", type=str,
                        help='Discard reads shorter than LEN.', default='1')
    parser.add_argument('-q', '--quality-cutoff', dest="min_trim_qual", type=str,
                        help='Trim low-quality bases from 5\' and/or 3\' ends of each read before adapter removal. Applied to both reads if data is paired. If one value is given, only the 3\' end is trimmed. If two comma-separated cutoffs are given, the 5\' end is trimmed with the first cutoff, the 3\' end with the second.',
                        default="0")
    parser.add_argument('-x', "--extra-options", dest="extra_options", type=str,
                        help="any extra parameters to pass to cutadapt", default='')
    args = parser.parse_args()

    if not os.path.isfile(args.input_R1):
        sys.exit('Error: specified input file %s does not exist or is not accessible!' % args.input_R1)
    if args.input_R2 and not os.path.isfile(args.input_R2):
        sys.exit('Error: specified input file %s does not exist or is not accessible!' % args.input_R2)
    if not os.path.isdir(args.output_dir):
        sys.exit('Error: specified output dir %s does not exist or is not accessible!' % args.output_dir)

    basename_R1=os.path.basename(args.input_R1)

    if args.input_R2:
      basename_R2=os.path.basename(args.input_R2)
      cmd = f"cutadapt -q {args.min_trim_qual} -m {args.min_trim_len} -a {args.adapter_R1} -A {args.adapter_R2} -o {args.output_dir}/trim_{basename_R1} -p {args.output_dir}/trim_{basename_R2} {args.input_R1} {args.input_R2}"
    else:
      cmd = f"cutadapt -q {args.min_trim_qual} -m {args.min_trim_len} -a {args.adapter_R1} -o {args.output_dir}/trim_{basename_R1} {args.input_R1}"


    stdout, stderr, returncode = run_cmd(cmd)
    # in case the rg_id contains filename not friendly characters
    friendly_rgid = "".join([ c if re.match(r"[a-zA-Z0-9\.\-_]", c) else "_" for c in args.rg_id ])
    # calculate md5 and add it in the logfile name to avoid name colision
    md5sum = hashlib.md5((args.rg_id).encode('utf-8')).hexdigest()

    logfile=f"{args.output_dir}/{friendly_rgid}.{md5sum}.cutadapt.log"
    with open(logfile,"w") as log:
        log.write(stdout)

    tool_ver=get_tool_version()
    qc_metrics_file = prep_qc_metrics(logfile, tool_ver)

    prepare_tarball(qc_metrics_file,logfile)



if __name__ == "__main__":
    main()
