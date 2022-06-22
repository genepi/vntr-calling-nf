nextflow.enable.dsl = 2

params.project="exome-validation"
params.input="$baseDir/test-data/*.bam"
params.gold="$baseDir/reference-data/gold/gold.txt"
params.region="$baseDir/reference-data/peterReadExtract.hg38.camo.LPA.realign.sorted.bed"
params.reference="$baseDir/reference-data/kiv2.fasta"
params.reference_fai="$baseDir/reference-data/kiv2.fasta.fai"
params.contig="KIV2_6"
params.threads = (Runtime.runtime.availableProcessors() - 1)
params.output="output"

bam_files_ch = Channel.fromPath(params.input)
//region_file_ch = file(params.region)
ref_fasta = file(params.reference)
ref_fasta_fai = file(params.reference_fai)
gold_standard = file(params.gold)
contig = file(params.contig)

mutserve_performance_java = "$baseDir/bin/MutservePerformance.java"
pattern_search_java  = file("$baseDir/bin/PatternSearch.java", checkIfExists: true)

if(params.build == "hg19") {
lpa_region = file("$baseDir/bin/lpa_hg19.bed", checkIfExists: true)
} else if (params.build == "hg38") {
lpa_region = file("$baseDir/bin/lpa_hg38.bed", checkIfExists: true)
}

requiredParams = [
    'project', 'input',
    'gold', 'reference', 'contig', 'build'
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

include { CACHE_JBANG_SCRIPTS         } from '../modules/local/cache_jbang_scripts'
include { BUILD_BWA_INDEX       } from '../modules/local/build_bwa_index'
include { DETECT_TYPE           } from '../modules/local/detect_type'  addParams(outdir: "$outdir")
include { EXTRACT_READS         } from '../modules/local/extract_reads'  addParams(outdir: "$outdir")
include { BAM_TO_FASTQ          } from '../modules/local/bam_to_fastq'  addParams(outdir: "$outdir")
include { REALIGN_FASTQ         } from '../modules/local/realign_fastq'  addParams(outdir: "$outdir")
include { CALL_VARIANTS_MUTSERVE} from '../modules/local/call_variants_mutserve'  addParams(outdir: "$outdir")
include { CALCULATE_PERFORMANCE } from '../modules/local/calculate_performance'  addParams(outdir: "$outdir")


workflow EXOME_CNV {

  CACHE_JBANG_SCRIPTS (pattern_search_java )
    BUILD_BWA_INDEX ( ref_fasta )
    DETECT_TYPE ( CACHE_JBANG_SCRIPTS.out.regenie_pattern_search_jar, bam_files_ch, lpa_region )
    EXTRACT_READS ( DETECT_TYPE.out.bam_bed_ch )
    BAM_TO_FASTQ ( EXTRACT_READS.out.extracted_bams_ch )
    REALIGN_FASTQ ( BAM_TO_FASTQ.out.fastq_ch,ref_fasta,BUILD_BWA_INDEX.out.bwa_index_ch )
    CALL_VARIANTS_MUTSERVE ( REALIGN_FASTQ.out.realigned_ch.collect(),ref_fasta, contig )
    CALCULATE_PERFORMANCE ( CALL_VARIANTS_MUTSERVE.out.variants_ch,gold_standard,mutserve_performance_java )
}
