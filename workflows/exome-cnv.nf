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
region_file_ch = file(params.region)
ref_fasta = file(params.reference)
ref_fasta_fai = file(params.reference_fai)
gold_standard = file(params.gold)
contig = file(params.contig)

mutserve_performance_java = "$baseDir/bin/MutservePerformance.java"


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

include { BUILD_BWA_INDEX       } from '../modules/local/build_bwa_index'
include { EXTRACT_READS         } from '../modules/local/extract_reads'
include { BAM_TO_FASTQ          } from '../modules/local/bam_to_fastq'
include { REALIGN_FASTQ         } from '../modules/local/realign_fastq'
include { CALL_VARIANTS_MUTSERVE} from '../modules/local/call_variants_mutserve'
include { CALL_VARIANTS_DEEPVARIANT} from '../modules/local/call_variants_deepvariant'
include { CALL_VARIANTS_FREEBAYES} from '../modules/local/call_variants_freebayes'
include { CALCULATE_PERFORMANCE } from '../modules/local/calculate_performance'


workflow EXOME_CNV {
    BUILD_BWA_INDEX ( ref_fasta )
    EXTRACT_READS ( bam_files_ch,region_file_ch )
    BAM_TO_FASTQ ( EXTRACT_READS.out.extracted_bams_ch )
    REALIGN_FASTQ ( BAM_TO_FASTQ.out.fastq_ch,ref_fasta,BUILD_BWA_INDEX.out.bwa_index_ch )
    CALL_VARIANTS_MUTSERVE ( REALIGN_FASTQ.out.realigned_ch.collect(),ref_fasta,contig )
    CALL_VARIANTS_DEEPVARIANT ( REALIGN_FASTQ.out.realigned_ch,ref_fasta, ref_fasta_fai )
    CALL_VARIANTS_FREEBAYES ( REALIGN_FASTQ.out.realigned_ch.collect(),ref_fasta, ref_fasta_fai )
    CALCULATE_PERFORMANCE ( CALL_VARIANTS_MUTSERVE.out.variants_ch,gold_standard,mutserve_performance_java )
}
