process MERGE_VARIANTS_MUTSERVE {
  
  publishDir "${params.outdir}/variant_calling", mode: "copy"

  input:
  path variants
  path variants_raw

  output:
  path "${params.project}.txt.gz"
  path "${params.project}_raw.txt.gz"
  """
  java -jar /opt/genomic-utils.jar csv-concat \
      --separator '\t' \
      --output-sep '\t' \
      --gz \
      --output ${params.project}.txt.gz \
      ${variants}

  java -jar /opt/genomic-utils.jar csv-concat \
      --separator '\t' \
      --output-sep '\t' \
      --gz \
      --output ${params.project}_raw.txt.gz \
      ${variants_raw}
  """
}
