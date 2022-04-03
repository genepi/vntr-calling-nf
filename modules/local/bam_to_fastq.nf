process BAM_TO_FASTQ {
    publishDir "${params.outdir}/fastq", mode: "copy"
  input:
	  path bamFile
  output:
	  tuple val("${bamFile.baseName}"), path("*.r1.fastq"), path("*.r2.fastq"), emit: fastq_ch
    path "*.fastq", emit: realigned_ch
	"""
	 bedtools bamtofastq -i ${bamFile} -fq ${bamFile.baseName}.r1.fastq -fq2 ${bamFile.baseName}.r2.fastq
	"""
}
