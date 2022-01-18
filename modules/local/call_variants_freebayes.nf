process CALL_VARIANTS_FREEBAYES {
  publishDir "${params.output}/freebayes", mode: "copy"

  input:
	   path bamFiles
		 path ref_fasta
     path ref_fasta_fai
  output:
	  path "${params.project}_freebayes.vcf", emit: variants_ch

	"""
  freebayes-1.3.4-linux-static-AMD64 -f ${ref_fasta} ${bamFiles} > ${params.project}_freebayes.vcf
	"""
}
