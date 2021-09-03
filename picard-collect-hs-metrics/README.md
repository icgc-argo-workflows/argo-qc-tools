# picard-collect-hs-metrics

Runs `picard CollectHsMetrics`.

Ref: picard tools [docs](https://broadinstitute.github.io/picard/command-line-overview.html).

## Usage:
```
Mandatory arguments:
    --aligned_seq       Input alignments, can be bam or cram.
    --ref_genome        Reference genome (uncompressed or bgzipped fasta file): *.[fa|fna|fasta] or *.[fa|fna|fasta].gz
                        The *.fai index must be available, as well as the *.gzi in case of a compressed fasta file.
    --target_intervals  Targets file in interval format (dictionary header + bed).
                        These are usually named as 'covered' files by the capture-kit provider.
    --bait_intervals    Baits file in interval format (dictionary header + bed).
                        These are usually named as 'padded' files by the capture-kit provider.
                        If not available, provide the targets file here as well.
```

