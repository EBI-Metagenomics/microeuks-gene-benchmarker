/*
    ~~~~~~~~~~~~~~~~~~
     Run subworkflow
    ~~~~~~~~~~~~~~~~~~
*/

include { BUSCO               } from '../modules/busco'
include { PLOT_COMPLETENESS   } from '../modules/plot_completeness'

workflow PROCESS_COMPLETENESS {

    take:
        braker_proteins
        galba_proteins
        metaeuk_proteins
        ref_proteins
        busco_db

    main:
        busco_input = ref_proteins.join(braker_proteins).join(galba_proteins).join(metaeuk_proteins).map { meta, ref, b, g, m ->
            def meta_braker = meta.clone()
            meta_braker.tool = "braker"

            def meta_galba = meta.clone()
            meta_galba.tool = "galba"

            def meta_metaeuk = meta.clone()
            meta_metaeuk.tool = "metaeuk"

            def meta_ref = meta.clone()
            meta_ref.tool = "ref"

            return tuple([
                tuple(meta_ref, ref),
                tuple(meta_braker, b),
                tuple(meta_galba, g),
                tuple(meta_metaeuk, m)
            ])
        }.flatMap()

        BUSCO(busco_input, busco_db)
        all_stats = BUSCO.out.busco_stats.collectFile(name: 'all_stats.txt')

        PLOT_COMPLETENESS(all_stats)
}