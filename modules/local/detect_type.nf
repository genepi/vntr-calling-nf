process DETECT_TYPE {
  publishDir "${params.outdir}/pattern", mode: "copy", pattern: '*pattern.txt'
  input:
    path bamFile
    path lpaRegion

  output:
    path "${bamFile.baseName}-pattern.txt", emit: detected_pattern
    tuple file("${bamFile.baseName}.extracted.bam"), path("${bamFile.baseName}.bed"), emit: bam_bed_ch

  script:
  def avail_mem = 1024
  if (!task.memory) {
      log.info 'Available memory not known - defaulting to 1GB. Specify process memory requirements to change this.'
  } else {
      avail_mem = (task.memory.mega*0.8).intValue()
  }

  """
  samtools view -h -L ${lpaRegion} ${bamFile} -o ${bamFile.baseName}.extracted.bam
  samtools fastq ${bamFile.baseName}.extracted.bam > ${bamFile.baseName}.fastq
  java -Xmx${avail_mem}M -jar /opt/PatternSearch.jar ${bamFile.baseName}.fastq --output ${bamFile.baseName}-pattern.txt --output-bed ${bamFile.baseName}.bed --splitValue ${params.signature_split_value} --pattern CCACTGTCACTGGAA,TTCCAGTGACAGTGG --build ${params.build}
  """

}
