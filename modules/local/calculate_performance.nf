process CALCULATE_PERFORMANCE {

publishDir "${params.outdir}/performance", mode: 'copy'

  input:
  path mutserve_file
  path gold_standard

  output:
  path "*.txt", emit: mutserve_performance_ch

  """
  java -jar /opt/MutservePerformance.jar --gold ${gold_standard} --output ${params.project}-performance.txt ${mutserve_file}
  """

}
