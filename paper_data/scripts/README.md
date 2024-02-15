# Running the VNTR-Resolver on the 1000G Phase 3 data

We run our pipeline on publicly available 1000 Genomes Phase 3 data (WES and 30x WGS, both mapped to hg38) for the LPA locus. To reproduce it, please execute the following:

* Download the data using the [WES script](download-1000G-wes-hg38.sh) and the [WGS script](download-1000G-wgs-hg38.sh)
* Create a config file (e.g. `1000g-exome-signature.config`).
```
params.project="1000g_exome_signature"
params.input="</data/1000g_phase3_lpa/*bam"
params.build="hg38"
params.reference="reference-data/kiv2.fasta"
params.contig="KIV2_6"
```
* Run the pipeline: `nextflow run genepi/vntr-resolver-nf -r v0.4.6 -profile singularity -c 1000g-exome-signature.config`
