# nf-qc-pipeline

Minimal Nextflow (DSL2) QC for paired-end bacterial reads:
- fastp (optional trimming)
- FastQC
- MultiQC

## Input
CSV with header `sample,R1,R2`, e.g.:
```csv
sample,R1,R2
Ecoli1,/abs/Ecoli1_R1.fastq.gz,/abs/Ecoli1_R2.fastq.gz