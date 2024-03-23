# vntr-calling-nf: An approach to resolve variants within VNTRs from sequencing data

## About
This repository includes an automated DSL2 Nextflow pipeline to resolve VNTRs (large variable number tandem repeats) from sequencing data in BAM format.

The pipeline has been applied to the **KIV-2 VNTR** of the **LPA gene** (using a novel signature-sequence approach) but can also be used for **other similar VNTRs** by specifying a region of interest.


## Quick Start

1) Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation) (>=21.04.0)

2) Run the pipeline on a test dataset

```
nextflow run genepi/vntr-calling-nf -r v0.4.9 -profile test,<docker,singularity>
```

3) Run the pipeline on your data

```
nextflow run genepi/vntr-calling-nf -c <nextflow.config> -r v0.4.9 -profile <docker,singularity>
```

## Parameters
### Required Parameters
| Tables        | Value           | Description  |
| ------------- |-------------| -------------|
| project       | my-project | Project name |
| input      |  /path/to/*.bam     |  Input WES BAM files |
| reference | /path/to/*fasta  |  Reference used for alignment and variant calling (e.g. single KIV-2 repeat). *fasta.fai file required. |
| contig |  KIV-2 |    Reference contig for variant calling  |

### Additional Parameters
| Tables        | Value           | Description  |
| ------------- |-------------| -------------|
| region | /path/to/bed   |  BED coordaintes for read extraction. Only required for other VNTRs than LPA. |
| build | hg19 or hg38    |  Specify build for signature detection. Only required for the LPA VNTR. |

## Implementation Details
For the LPA gene, the workflow uses WES reads aligned to the complete reference genome as an input. First, the complete LPA region is extracted, converted to FASTQ, and screened for the KIV-2B signature sequence. KIV-2 reads are then extracted using a novel signature-sequence approach and remapped to a reference consisting of one single KIV-2 repeat. Using this approach, KIV-2 variants are naturally present only in a subset of reads like somatic mutations and are called using mutserve with settings optimized for low-level variant detection.

We tested and validated the WES pipeline on a gold-standard dataset with known LPA KIV-2 variant patterns and benchmarked it by applying it to the 200K UK Biobank WES dataset.

## Regions Of Interests (ROIs)
For LPA, we tested several read extraction strategies (ROI-1 to ROI-9), which can be downloaded from [this repository](paper_data/bed) and are also referenced in the paper. 

## Pipeline Steps
* Build BWA Index on the reference genome
* Detect KIV2 LPA type (LPA only)
* Extract reads from the defined bed region
* Convert region to FASTQ
* Realign region to a single repeat
* Call variants using [mutserve](https://github.com/seppinho/mutserve)

## Example Configurations

### LPA VNTR
```
params.project="bgi"
params.input="bams_bgi/*bam"
params.reference="reference-data/kiv2.fasta"
params.contig="KIV2_6"
params.build="hg19"
```

### Other VNTRs
```
params.project="2_JLR_no_mapq"
params.input="bams_bgi/*bam"
params.reference="reference-data/kiv2.fasta"
params.contig="KIV2_6"
params.region="bed/hg37/2_JLR_strategy_hg19.bed"
```

## Paper Analysis
Final VNTR variant calling data, all required steps and input files or steps are described [here](paper_data).



## Development

```
docker build -t genepi/vntr-calling-nf . # don't ingore the dot here
nextflow run main.nf -profile test,development
```

## License
The pipeline is MIT Licensed.
