# Resolving VNTRs in Whole-exome sequencing data

## About
An automated DSL2 Nextflow pipeline to resolve VNTRs (large variable number tandem repeats) from whole-exome sequencing data in BAM format. 

## Pipeline Steps
* Build BWA Index on the reference genome
* Detect KIV2 LPA type 
* Extract reads from the LPA region
* Convert region to FASTQ
* Realign region to a single repeat
* Call variants using mutserve
* Calculate F1-score performance (optional) 


## Quick Start

1) Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation) (>=21.04.0)

2) Run the pipeline on a test dataset

```
nextflow run genepi/exome-cnv-nf -r v0.3.2 -profile test,<docker,singularity>
```

3) Run the pipeline on your data

```
nextflow run genepi/exome-cnv-nf -c <nextflow.config> -r v0.3.2 -profile <docker,singularity>
```

## Development

```
docker build -t genepi/exome-cnv-nf . # don't ingore the dot here
nextflow run main.nf -profile test,development
```

## License
The pipeline is MIT Licensed.
