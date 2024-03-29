process REALIGN_FASTQ {
  input:
  tuple val(baseName), path(r1_fastq), path(r2_fastq)
  path ref_fasta
  path "*"

  output:
  path "*.kiv2.realigned.bam", emit: realigned_ch

	"""
	bwa mem -M ${ref_fasta} -R "@RG\\tID:LPA-exome-${baseName}\\tSM:${baseName}\\tPL:ILLUMINA" ${r1_fastq} ${r2_fastq} | samtools sort -o ${baseName}.kiv2.realigned.bam -
	"""
}
