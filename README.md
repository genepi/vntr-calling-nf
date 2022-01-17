# CNV Exome

> Decipher CNVs in NGS short-read data. 


## Quick Start

1) Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation) (>=21.04.0)

2) Run the pipeline on a test dataset

```
nextflow run genepi/exome-cnv-nf -r v0.0.2 -profile test,<docker,singularity>
```

3) Run the pipeline on your data

```
nextflow run genepi/gwas-regenie -c <nextflow.config> -r v0.0.2 -profile <docker,singularity>
```

## Development

```
docker build -t genepi/lpa-exome . # don't ingore the dot here
nextflow run main.nf -profile test,development
```

## License
LPA Exome is MIT Licensed.
