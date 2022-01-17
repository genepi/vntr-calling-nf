process CALCULATE_PERFORMANCE {

publishDir "$params.output", mode: 'copy'

  input:
  path mutserve_file
  path gold_standard
  path mutserve_performance

  output:
  path "*.txt", emit: mutserve_performance_ch

  """
  jbang ${mutserve_performance} --gold ${gold_standard} --output ${params.project}-performance.txt ${mutserve_file}
  """

}