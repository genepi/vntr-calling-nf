# LPA Exome

> Nextflow pipeline to execute Regenie, create Manhattan-Plots and annotate GWAS results

## Requirements

- Nextflow:

```
curl -s https://get.nextflow.io | bash
```

- Docker

## Installation

Build docker image before run the pipeline:

```
docker build -t genepi/lpa-exome . # don't ingore the dot here
```


Test the pipeline and the created docker image with test-data:

```
nextflow run main.nf
```

## License
LPA Exome is MIT Licensed.
