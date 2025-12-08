process EXTRACT_READS {

  input:
  tuple path(bamFile), path(regionFile)

  output:
  path "*.extracted.bam", emit: extracted_bams_ch

  """
  samtools view --threads $task.cpus -hb -L ${regionFile} ${bamFile} | samtools sort $task.cpus -n -o ${bamFile.baseName}.extracted.bam -
	"""
}
