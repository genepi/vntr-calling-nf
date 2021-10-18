process BUILD_BWA_INDEX {

    input:
    path ref_fasta

    output:
    path "*.{amb,ann,bwt,pac,sa}", emit: bwa_index_ch

    """
    bwa index "${ref_fasta}"
    """
}
