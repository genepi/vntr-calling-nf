process CALL_VARIANTS_MUTSERVE {
  
  //publishDir "${params.outdir}/mutserve", mode: "copy"

  input:
  path bam_file
  path ref_fasta
  val(contig)

  output:
  path "${bam_file.simpleName}.txt", emit: variants_ch
  path "${bam_file.simpleName}_raw.txt", emit: variants_raw_ch

  script:
  def avail_mem = 1024
  if (!task.memory) {
      //log.info 'Available memory not known - defaulting to 1GB. Specify process memory requirements to change this.'
  } else {
      avail_mem = (task.memory.mega*0.8).intValue()
  }

  """
	java -Xmx${avail_mem}M -jar /opt/mutserve/mutserve.jar \
      call \
      --output ${bam_file.simpleName}.txt \
      --write-raw \
      --reference ${ref_fasta} \
      --level ${params.mutserve_detection_limit} \
      --deletions \
      --baseQ ${params.mutserve_baseQ} \
      --mapQ ${params.mutserve_mapQ} \
      --alignQ ${params.mutserve_alignQ} \
      --contig-name ${contig} \
      --no-ansi \$PWD
	"""
}
