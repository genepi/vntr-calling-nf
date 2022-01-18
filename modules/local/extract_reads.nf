process EXTRACT_READS {
  input:
	  path bamFile
		path regionFile
  output:
	  path "*.extracted.bam", emit: extracted_bams_ch
	"""
	samtools view -h -L ${regionFile} ${bamFile} | awk '\$5 < 10 || \$1 ~ "^@"' | samtools view -hb - | samtools sort -n -o ${bamFile.baseName}.extracted.bam -
	"""
}
