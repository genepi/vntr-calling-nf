# Paper data

This README summarizes the location of all input and output files to reproduce our results.  

## Results
The final outputs of the pipeline can be accessed [here](vntrs). The folder includes all required files for running the pipeline and the annotation process. 

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
* We executed this experiment on our Slurm cluster using default configured CPUs and memory and we were able to run the data in 33 min (CPU hours: 7,5). Click [here](https://html-preview.github.io/?url=https://raw.githubusercontent.com/genepi/vntr-calling-nf/main/paper_data/results/1000g-wgs-signature.html) to analyze the Nextflow report. 

## Detection of Paralogous Sequence Variants (PSVs)

In our paper, we detect paralogous sequence variants (PSVs) for each analyzed VNTR.  We show that PSVs allows pinpointing the positions where reference-based artifacts are likely to result in false positive calls. The following steps have been applied.

Steps:
1) Download [all repeats](psvs/clustalO_input) using e.g. USCS Genome Browser. 
2) Create reverse complement for regions on the minus strand.
3) Run multiple sequence alignment with [clustalO](https://www.ebi.ac.uk/Tools/msa/clustalo) (select DNA instead of Protein!)
4) Download [clustalO files](psvs/clustalO_result) and use as input for this [algorithm](scripts/FastaUtil.java) developed by us.
   This script compares all repeats and outputs all differences in the reference within the repeats. This then constitutes the list of PSVs.

```
jbang export portable --verbose -O=FastaUtil.jar FastaUtil.java
java -jar FastaUtil.jar --input "clustalO_result/aln-fasta-lpa.txt" --output "LPA-psvs.txt"
```

### Results
The final PSV results (using the described workflow from above) can be found [here](psvs/results).


## Variant Annotation

For variant annotation, we use a in-house developed [annotation tool](https://github.com/lukfor/genepi-annotate) and can be executed as follows:

```
java genepi-annotate.jar --input variants_lpa.txt --mutation Variant --reference  refs/LPA.fasta --position Pos --maplocus maplocus/MapLocusLPA.txt  --columnwt wt_aas --columnmut mut_aas  --output variants_lpa_annotated.txt
```

### How does annotation work?

The annotation uses an annotation file (maplocus-file in our internal naming), which is a tabular file that describes the genetic features in the specified reference sequence for a single VNTR unit. In brief, it assigns a freely definable denominator (column map_locus) to portions of the reference sequence, as specified by the position columns. Also a shorthand denominator and a description of the defined region can be added in the respective columns. The columns “coding” and “translated” define whether our annotation tool should translate the respective sequence sequence. The column “ReadingFrame” then specifies whether the translation, respectively reading frame starts at base 1 2 or 3 of the respective feature. 