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

include { VNTR_CALLER } from './workflows/vntr-caller'

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

workflow {
    VNTR_CALLER ()
}
