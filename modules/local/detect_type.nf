process DETECT_TYPE {
  cpus 3

  input:
    path bamFile
    path lpaRegion

  output:
    path "${bamFile.baseName}-pattern.txt", emit: detected_pattern
    path "${bamFile.baseName}.fastq"
    tuple file("${bamFile.baseName}.extracted.bam"), path("${bamFile.baseName}.bed"), emit: bam_bed_ch

  """
  samtools view -h -L ${lpaRegion} ${bamFile} -o ${bamFile.baseName}.extracted.bam
  samtools fastq ${bamFile.baseName}.extracted.bam > ${bamFile.baseName}.fastq
  java -jar /opt/PatternSearch.jar ${bamFile.baseName}.fastq --output ${bamFile.baseName}-pattern.txt --output-bed ${bamFile.baseName}.bed --splitValue ${params.signature_split_value} --pattern CCACTGTCACTGGAA,TTCCAGTGACAGTGG --build ${params.build}
  """

}
