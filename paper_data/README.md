# Paper data

This README summarizes the location of all input and output files to reproduce our results.  

## Running the VNTR Variant-Calling on the 1000G Phase 3 data

In our paper, we run our pipeline on the publicly available 1000 Genomes Phase 3 data (30x WGS, mapped to hg38) for the LPA locus. To reproduce it, please execute the following steps:

1) Download the data using the provided [WGS script](scripts/download-1000G-wgs-hg38.sh).
2) Create a Nextflow config file locally (e.g. `1000g-wgs.config`) and install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation).
```
params.project="1000g_wgs_signature"
params.input="1000g_phase3_lpa/*bam"
params.build="hg38"
params.reference="reference-data/kiv2.fasta"
params.contig="KIV2_6"
```
3) Run the pipeline: `nextflow run genepi/vntr-calling-nf -r v0.4.9 -profile <docker,singularity,slurm> -c 1000g-wgs.config`

### Notes
* Please note that either **docker**, **singularity** or **slurm** must be available and has to be specified according to your system. Most likely, Docker is only available on your local system (since it requires root permissions for execution). 
* The `params.input` parameter must be adapted to the location of your BAM files.
* Reference data for `params.reference` is located [here](../reference-data).
* We executed this experiment on our Slurm cluster using default configured CPUs and memory and we were able to run the data in 33 min (CPU hours: 7,5). See [here]() for details. 
