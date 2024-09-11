#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BENCHMARKER } from './workflows/benchmarker'

workflow  {
    BENCHMARKER ()
}

