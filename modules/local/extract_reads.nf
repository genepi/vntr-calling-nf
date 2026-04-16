process EXTRACT_READS {

  input:
  tuple path(bamFile), path(regionFile)

  output:
  path "*.extracted.bam", emit: extracted_bams_ch
  
  script:
  def cram_command = bamFile.Extension == "cram" ? "-T ${params.reference_genome}" : ""
  """
  samtools \
      view \
      --threads $task.cpus \
      -hb \
      -L ${regionFile} ${cram_command} \
      ${bamFile} | \
      samtools \
      sort \
      --threads $task.cpus \
      -n \
      -o ${bamFile.baseName}.extracted.bam -
  """
}
