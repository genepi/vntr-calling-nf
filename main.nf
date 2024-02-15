#!/usr/bin/env nextflow
/*
========================================================================================
    genepi/exome-cnv-nf
========================================================================================
    Github : https://github.com/seppinho/exome-cnv-nf
    Author: Sebastian Schönherr
    ---------------------------
*/

nextflow.enable.dsl = 2

include { VNTR_RESOLVER } from './workflows/vntr-resolver'

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

workflow {
    VNTR_RESOLVER ()
}
