process CALL_VARIANTS_MUTSERVE {
  publishDir "${params.outdir}/mutserve", mode: "copy"
  input:
	   path bamFile
		 path ref_fasta
		 path contig
  output:
	  path "${params.project}.txt", emit: variants_ch
    path "${params.project}_raw.txt", emit: variants_raw_ch
	"""
	mutserve call --output ${params.project}.vcf --write-raw --reference ${ref_fasta} --deletions --contig-name ${contig} ${bamFile} --no-ansi
	"""
}
