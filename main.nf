nextflow.enable.dsl = 2

params.project="exome-validation"
params.input="$baseDir/test-data/*.bam"
params.gold="$baseDir/reference-data/gold/gold.txt"
params.region="$baseDir/reference-data/peterReadExtract.hg38.camo.LPA.realign.sorted.bed"
params.reference="$baseDir/reference-data/kiv2.fasta"
params.contig="KIV2_6"
params.threads = (Runtime.runtime.availableProcessors() - 1)
params.output="output"

bam_files_ch = Channel.fromPath(params.input)
region_file_ch = file(params.region)
ref_fasta = file(params.reference)
gold_standard = file(params.gold)
contig = file(params.contig)

MutservePerformance = "$baseDir/bin/MutservePerformance.java"


requiredParams = [
    'project', 'input',
    'gold', 'region',
    'reference', 'contig'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

if(params.outdir == null) {
  outdir = "output/${params.project}"
} else {
  outdir = params.outdir
}

process BUILD_BWA_INDEX {

    input:
    path ref_fasta

    output:
    path "*.{amb,ann,bwt,pac,sa}", emit: bwa_index_ch

    """
    bwa index "${ref_fasta}"
    """
}

process EXTRACT_READS {
  input:
	  path bamFile
		path regionFile
  output:
	  path "*.extracted.bam", emit: extracted_bams_ch
	"""
	samtools view -h -@ 15 -L ${regionFile} ${bamFile} | awk '\$5 < 10 || \$1 ~ "^@"' | samtools view -hb - | samtools sort -n -@ 15 -o ${bamFile.baseName}.extracted.bam -
	"""
}


process BAM_TO_FASTQ {
  input:
	  path bamFile
  output:
	  tuple val("${bamFile.baseName}"), path("*.r1.fastq"), path("*.r2.fastq"), emit: fastq_ch
	"""
	 bedtools bamtofastq -i ${bamFile} -fq ${bamFile.baseName}.r1.fastq -fq2 ${bamFile.baseName}.r2.fastq
	"""
}

process REALIGN_FASTQ {
  publishDir "${params.output}", mode: "copy"
  input:
	   tuple val(baseName), path(r1_fastq), path(r2_fastq)
		 path ref_fasta
		 path "*"
  output:
	  path "*.kiv2.realigned.bam", emit: realigned_ch
	"""
	bwa mem -M ${ref_fasta} -R "@RG\\tID:LPA-exome-${baseName}\\tSM:${baseName}\\tPL:ILLUMINA" ${r1_fastq} ${r2_fastq} | samtools sort -@ 15 -o ${baseName}.kiv2.realigned.bam -

	"""
}


process CALL_VARIANTS {
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


process CALCULATE_PERFORMANCE {

publishDir "$params.output", mode: 'copy'

  input:
  path mutserve_file
  path gold_standard

  output:
  path "*.txt", emit: mutserve_performance_ch

  """
  jbang ${MutservePerformance} --gold ${gold_standard} --output ${params.project}-performance.txt ${mutserve_file}
  """

}


workflow {
    BUILD_BWA_INDEX(ref_fasta)
    EXTRACT_READS(bam_files_ch,region_file_ch)
    BAM_TO_FASTQ(EXTRACT_READS.out.extracted_bams_ch)
    REALIGN_FASTQ(BAM_TO_FASTQ.out.fastq_ch,ref_fasta,BUILD_BWA_INDEX.out.bwa_index_ch)
    CALL_VARIANTS(REALIGN_FASTQ.out.realigned_ch.collect(),ref_fasta,contig)
    CALCULATE_PERFORMANCE(CALL_VARIANTS.out.variants_ch,gold_standard)
}
