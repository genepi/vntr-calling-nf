process EXTRACT_READS {
    publishDir "${params.output}/extracted_bams", mode: "copy"
  input:
	  path bamFile
		path regionFile
  output:
	  path "*.extracted.bam", emit: extracted_bams_ch
	"""
	samtools view -h -L ${regionFile} ${bamFile} | awk '\$5 < ${params.reads_quality_limit} || \$1 ~ "^@"' | samtools view -hb - | samtools sort -n -o ${bamFile.baseName}.extracted.bam -
	"""
}
