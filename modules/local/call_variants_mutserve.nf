process CALL_VARIANTS_MUTSERVE {
  publishDir "${params.outdir}/mutserve", mode: "copy"

  input:
	   path bamFiles
		 path ref_fasta
		 path contig

  output:
	  path "${params.project}.txt", emit: variants_ch
    path "${params.project}_raw.txt", emit: variants_raw_ch

  """
	mutserve call --output ${params.project}.vcf --write-raw --reference ${ref_fasta} --level ${params.mutserve_detection_limit} --deletions --baseQ ${params.mutserve_baseQ} --mapQ ${params.mutserve_mapQ} --alignQ ${params.mutserve_alignQ} --contig-name ${contig} --no-ansi \$PWD
	"""
}
