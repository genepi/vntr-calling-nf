process CALCULATE_PERFORMANCE {
  publishDir "${params.outdir}/performance", mode: 'copy'
  input:
  path mutserve_file
  path gold_standard

  output:
  path "*.txt", emit: mutserve_performance_ch

  script:
  def avail_mem = 1024
  if (!task.memory) {
      //log.info 'Available memory not known - defaulting to 1GB. Specify process memory requirements to change this.'
  } else {
      avail_mem = (task.memory.mega*0.8).intValue()
  }

  """
  java -Xmx${avail_mem}M -jar /opt/MutservePerformance.jar \
      --gold ${gold_standard} \
      --output ${params.project}-performance.txt \
      ${mutserve_file}
  """
}
