# Paper data

This README summarizes the location of all input and output files to reproduce our results.  

## Running the VNTR Variant-Calling on the 1000G Phase 3 data

In our paper, we run our pipeline on the publicly available 1000 Genomes Phase 3 data (30x WGS, mapped to hg38) for the LPA locus. To reproduce it, please execute the following steps:

* 1) Download the data using the [WGS script](scripts/download-1000G-wgs-hg38.sh)
* 2) Create a Nextflow config file locally (e.g. `1000g-wgs.config`) and install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation).
```
params.project="1000g_wgs_signature"
params.input="</data/1000g_phase3_lpa/*bam"
params.build="hg38"
params.reference="reference-data/kiv2.fasta"
params.contig="KIV2_6"
```
* 3) Run the pipeline: `nextflow run genepi/vntr-calling-nf -r v0.4.9 -profile <docker,singularity,slurm> -c 1000g-wgs.config`
*Please note that either **docker**, **singularity** or **slurm** must be available and specified depending on your system*
