/*
    ~~~~~~~~~~~~~~~~~~
     Run subworkflow
    ~~~~~~~~~~~~~~~~~~
*/

include { COUNT_EXONS        } from '../modules/count_exons'
include { PLOT_EXON_COUNTS   } from '../modules/plot_exon_counts'

workflow PROCESS_EXONS {

    take:
        gffs

    main:

        COUNT_EXONS(gffs)

        PLOT_EXON_COUNTS(COUNT_EXONS.out.exons_table)
}