# nf-qc-pipeline

Nextflow QC for paired-end bacterial reads:
- fastp (optional trimming)
- FastQC
- MultiQC

## Input
CSV with header `sample,R1,R2`, e.g.:

```csv
sample,R1,R2
Ecoli1,/abs/Ecoli1_R1.fastq.gz,/abs/Ecoli1_R2.fastq.gz
```

## Usage
Run the pipeline with Conda:

```bash
nextflow run . -profile conda --samples samples.csv --outdir results --trim true
```
