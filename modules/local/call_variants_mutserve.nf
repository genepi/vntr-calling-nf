process CALL_VARIANTS_MUTSERVE {
  publishDir "${params.output}", mode: "copy"
  input:
	   path bamFile
		 path ref_fasta
		 path contig
  output:
	  path "${params.project}.txt", emit: variants_ch
	"""
	mutserve call --output ${params.project}.vcf --reference ${ref_fasta} --deletions --contig-name ${contig} ${bamFile} --no-ansi
	"""
}
