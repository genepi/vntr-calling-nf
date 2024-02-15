process EXTRACT_READS {

  input:
  tuple path(bamFile), path(regionFile)

  output:
  path "*.extracted.bam", emit: extracted_bams_ch

  """
  samtools view -hb -L ${regionFile} ${bamFile} | samtools sort -n -o ${bamFile.baseName}.extracted.bam -
	"""
}
