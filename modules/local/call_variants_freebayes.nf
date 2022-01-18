process CALL_VARIANTS_FREEBAYES {
  publishDir "${params.output}", mode: "copy"

  input:
	   path bamFiles
		 path ref_fasta
     path ref_fasta_fai
  output:
	  path "${params.project}.vcf", emit: variants_ch

	"""
  freebayes-1.3.4-linux-static-AMD64 -f ${ref_fasta} ${bamFiles} > ${params.project}.vcf
	"""
}
