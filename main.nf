nextflow.enable.dsl = 2

// defaults
params.samples = params.samples ?: 'samples.csv'
params.outdir  = params.outdir  ?: 'results'
params.trim    = (params.trim in [false, 'false']) ? false : true

// samples: CSV with header sample,R1,R2
Channel
  .fromPath(params.samples)
  .splitCsv(header: true)
  .map { row ->
    if( !row.sample || !row.R1 || !row.R2 )
      throw new IllegalArgumentException('CSV must have columns: sample,R1,R2')
    tuple(row.sample as String, [ file(row.R1), file(row.R2) ])
  }
  .set { SAMPLES }

process FASTP {
  tag "$sample"
  publishDir "${params.outdir}/fastp", mode: 'copy'

  input:
    tuple val(sample), path(reads)

  output:
    tuple val(sample),
          path("${sample}.clean.R1.fastq.gz"),
          path("${sample}.clean.R2.fastq.gz"),
          emit: reads
    path "${sample}.fastp.html", emit: html
    path "${sample}.fastp.json", emit: json

  when:
    params.trim

  """
  fastp \
    --in1 ${reads[0]} --in2 ${reads[1]} \
    --out1 ${sample}.clean.R1.fastq.gz \
    --out2 ${sample}.clean.R2.fastq.gz \
    --thread 4 \
    --html ${sample}.fastp.html \
    --json ${sample}.fastp.json
  """
}

process FASTQC {
  tag "$sample"
  publishDir "${params.outdir}/fastqc", mode: 'copy'

  input:
    tuple val(sample), path(reads)

  output:
    path "*_fastqc.zip",  emit: zips
    path "*_fastqc.html", emit: html

  """
  fastqc -t 4 ${reads.join(' ')}
  """
}

process MULTIQC {
  publishDir "${params.outdir}/multiqc", mode: 'copy'

  input:
    path(qc_files)

  output:
    path "multiqc_report.html"
    path "multiqc_data"

  """
  multiqc -f -o . .
  """
}

workflow {
  trimmed      = FASTP(SAMPLES)
  reads_for_qc = params.trim ? trimmed.reads : SAMPLES
  fastqc_out   = FASTQC(reads_for_qc)

  all_qc_files =
    fastqc_out.zips
      .mix(fastqc_out.html)
      .mix(params.trim ? trimmed.html : Channel.empty())
      .mix(params.trim ? trimmed.json : Channel.empty())
      .collect()

  MULTIQC(all_qc_files)
}