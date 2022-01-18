process CALL_VARIANTS_DEEPVARIANT {
  publishDir "${params.output}", mode: "copy"
  container 'google/deepvariant:1.3.0'

  input:
	   path bamFile
		 path ref_fasta
     path ref_fasta_fai
  output:
	  path "${bamFile}.vcf", emit: variants_ch

	"""
  samtools index ${bamFile}
	/opt/deepvariant/bin/run_deepvariant --model_type=WES --output_vcf ${bamFile}.vcf --ref ${ref_fasta} --reads ${bamFile}
	"""
}
