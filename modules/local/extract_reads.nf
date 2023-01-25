process EXTRACT_READS {
  cpus 3

  input:
    tuple val(bamFile), path(regionFile)

  output:
	  path "*.extracted.bam", emit: extracted_bams_ch

  """
  samtools view -hb -L ${regionFile} ${bamFile} | samtools sort -n -o ${bamFile.baseName}.extracted.bam -
	"""
}
