nextflow.enable.dsl = 2

requiredParams = [
    'project', 'input','reference', 'contig'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

if (params.region == null && params.build == null) {
  exit 1, "Please specify build of your input data."
}

bam_files_ch = Channel.fromPath(params.input)
ref_fasta = file(params.reference, checkIfExists: true)
ref_fasta_fai = file(params.reference+".fai", checkIfExists: true)
contig = params.contig

outdir = "output/${params.project}"

include { BUILD_BWA_INDEX       } from '../modules/local/build_bwa_index'
include { DETECT_TYPE           } from '../modules/local/detect_type'  addParams(outdir: "$outdir")
include { EXTRACT_READS         } from '../modules/local/extract_reads'  addParams(outdir: "$outdir")
include { BAM_TO_FASTQ          } from '../modules/local/bam_to_fastq'  addParams(outdir: "$outdir")
include { REALIGN_FASTQ         } from '../modules/local/realign_fastq'  addParams(outdir: "$outdir")
include { CALL_VARIANTS_MUTSERVE} from '../modules/local/call_variants_mutserve'  addParams(outdir: "$outdir")
include { CALCULATE_PERFORMANCE } from '../modules/local/calculate_performance'  addParams(outdir: "$outdir")


workflow VNTR_CALLING {

    BUILD_BWA_INDEX ( ref_fasta )

    // if no region is set, we apply our LPA-specific signature approach
    if (params.region == null){
      // load lpa region, concrecte bed file is then defined in DETECT_TYPE
      if(params.build == "hg19") {
        lpa_region = file("$baseDir/bin/lpa_hg19.bed", checkIfExists: true)
      } else if (params.build == "hg38") {
        lpa_region = file("$baseDir/bin/lpa_hg38.bed", checkIfExists: true)
      }
    DETECT_TYPE ( bam_files_ch, lpa_region )
    bam_bed_tuple = DETECT_TYPE.out.bam_bed_ch
    // for all other regions use the defined region file
    } else {
      region = file(params.region, checkIfExists: true)
      bam_files_ch.map { it -> [it, region] }
           .set { bam_bed_tuple }
    }

    EXTRACT_READS ( bam_bed_tuple )
    BAM_TO_FASTQ ( EXTRACT_READS.out.extracted_bams_ch )
    REALIGN_FASTQ ( BAM_TO_FASTQ.out.fastq_ch,ref_fasta,BUILD_BWA_INDEX.out.bwa_index_ch )
    CALL_VARIANTS_MUTSERVE ( REALIGN_FASTQ.out.realigned_ch.collect(),ref_fasta, contig )

    if(params.gold != null) {
      gold_standard = file(params.gold, checkIfExists: true)
      CALCULATE_PERFORMANCE ( CALL_VARIANTS_MUTSERVE.out.variants_ch,gold_standard )
    }
}
