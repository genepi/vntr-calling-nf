process BAM_TO_FASTQ {
  input:
  path bamFile

  output:
  tuple val("${bamFile.baseName}"), path("*.r1.fastq"), path("*.r2.fastq"), emit: fastq_ch
  path "*.fastq", emit: realigned_ch

	"""
  samtools fastq -1 ${bamFile.baseName}.r1.fastq -2 ${bamFile.baseName}.r2.fastq -0 /dev/null -s /dev/null -n ${bamFile}
	"""
}
