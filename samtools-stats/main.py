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
    Junjun Zhang
"""

import os
import sys
import argparse
import subprocess
from multiprocessing import cpu_count
from glob import glob
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
    get_tool_version_cmd = "samtools --version | grep '^samtools'"
    stdout, stderr, returncode = run_cmd(get_tool_version_cmd)
    if returncode:
        sys.exit(f"Error: unable to get version info for samtools.\nStdout: {stdout}\nStderr: {stderr}\n")

    return stdout.strip().split(' ')[-1]


def prep_qc_metrics(agg_bamstat, tool_ver):
    qc_metrics = {
        'tool': {
            'name': 'samtools:stats',
            'version': tool_ver
        },
        'metrics': {}
    }

    collected_sum_fields = {
        'raw total sequences': 'total_reads',
        'reads mapped': 'mapped_reads',
        'reads paired': 'paired_reads',
        'reads properly paired': 'properly_paired_reads',
        'pairs on different chromosomes': 'pairs_on_different_chromosomes',
        'total length': 'total_bases',
        'bases mapped (cigar)': 'mapped_bases_cigar',
        'mismatches': 'mismatch_bases',
        'error rate': 'error_rate',
        'bases duplicated': 'duplicated_bases',
        'insert size average': 'average_insert_size',
        'average length': 'average_length'
    }

    with open(agg_bamstat, 'r') as f:
        for row in f:
            if not row.startswith('SN\t'):
                continue
            cols = row.replace(':', '').strip().split('\t')
            if cols[1] not in collected_sum_fields:
                continue

            qc_metrics['metrics'].update({
                collected_sum_fields[cols[1]]: float(cols[2]) if ('.' in cols[2] or 'e' in cols[2]) else int(cols[2])
            })

    qc_metrics_file = 'qc_metrics.json'
    with open(qc_metrics_file, "w") as j:
        j.write(json.dumps(qc_metrics, indent=2))

    return qc_metrics_file


def prepare_tarball(aligned_seq, qc_metrics, agg_bamstat, lane_bamstat):
    tar_content = {
        'qc_metrics': qc_metrics,
        'agg_bamstat': agg_bamstat,
        'lane_bamstat': lane_bamstat
    }

    with open('tar_content.json', 'w') as t:
        t.write(json.dumps(tar_content, indent=2))

    files_to_tar = ['tar_content.json', qc_metrics, agg_bamstat] + lane_bamstat

    tarfile_name = f"{os.path.basename(aligned_seq)}.samtools_stats.qc.tgz"
    with tarfile.open(tarfile_name, "w:gz") as tar:
        for f in files_to_tar:
            tar.add(f, arcname=os.path.basename(f))


def main(aligned_seq, reference, threads=1):
    # get samtools version info
    tool_ver = get_tool_version()

    # run samtools stats
    stats_args = [
        '--reference', reference,
        '-@', str(threads),
        '-r', reference,
        '--split', 'RG',
        '-P', os.path.join(os.getcwd(), os.path.basename(aligned_seq))
    ]

    cmd = ['samtools', 'stats'] + stats_args + [aligned_seq]
    stdout, stderr, returncode = run_cmd(" ".join(cmd))
    if returncode:
        sys.exit(f"Error: 'samtools stats' failed.\nStdout: {stdout}\nStderr: {stderr}\n")

    agg_bamstat = f"{os.path.basename(aligned_seq)}.bamstat"
    with open(agg_bamstat, 'w') as f:
        f.write(stdout)

    # parse samtools stats output and put it in qc_metrics.json
    qc_metrics_file = prep_qc_metrics(agg_bamstat, tool_ver)

    lane_bamstat = []
    for f in sorted(glob('*.bamstat')):
        if f != agg_bamstat:
            lane_bamstat.append(f)

    # prepare tarball to include output files and qc_metrics.json
    prepare_tarball(aligned_seq, qc_metrics_file, agg_bamstat, lane_bamstat)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Tool: samtools-stats')
    parser.add_argument('-s', '--aligned_seq', type=str,
                        help='Input aligned seq', required=True)
    parser.add_argument('-r', '--reference', type=str,
                        help='Reference genome', required=True)
    parser.add_argument('-t', '--threads', type=int, default=cpu_count(),
                        help='Number of threads')
    args = parser.parse_args()

    if not os.path.isfile(args.aligned_seq):
        sys.exit('Error: specified aligned seq file %s does not exist or is not accessible!' % args.aligned_seq)

    if not os.path.isfile(args.reference):
        sys.exit('Error: specified reference file %s does not exist or is not accessible!' % args.reference)

    main(args.aligned_seq, args.reference, args.threads)
