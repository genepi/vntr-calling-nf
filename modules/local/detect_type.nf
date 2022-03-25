process DETECT_TYPE {

publishDir "$params.output", mode: 'copy'

  input:
  path pattern_search_java
  path bamFile
  path lpaRegion

  output:
  path "${bamFile.baseName}-pattern.txt", emit: detected_pattern

  """
  samtools view -h -L ${lpaRegion} ${bamFile} | awk '\$5 < ${params.reads_quality_limit} || \$1 ~ "^@"' | samtools view -hb - | samtools sort -n -o ${bamFile.baseName}.extracted.bam -
  bedtools bamtofastq -i ${bamFile.baseName}.extracted.bam -fq ${bamFile.baseName}.fastq
  export JBANG_CACHE_DIR=. && jbang ${pattern_search_java} ${bamFile.baseName}.fastq --output ${bamFile.baseName}-pattern.txt --pattern CCACTGTCACTGGAA,TTCCAGTGACAGTGG
"""

}
