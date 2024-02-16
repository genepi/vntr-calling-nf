process MERGE_VARIANTS_MUTSERVE {
  
  publishDir "${params.outdir}/variant_calling", mode: "copy"

  input:
  path variants
  path variants_raw

  output:
  path "${params.project}.txt.gz"
  path "${params.project}_raw.txt.gz"
  """
	csvtk concat -t ${variants} -T -o ${params.project}.txt.gz
  csvtk concat -t ${variants_raw} -T -o ${params.project}_raw.txt.gz
  """
}
