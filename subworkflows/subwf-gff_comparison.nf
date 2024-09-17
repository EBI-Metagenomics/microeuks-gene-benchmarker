/*
    ~~~~~~~~~~~~~~~~~~
     Run subworkflow
    ~~~~~~~~~~~~~~~~~~
*/

include { REFORMAT_GFF       } from '../modules/reformat_gff'
include { GFFCOMPARE         } from '../modules/gffcompare'
include { PLOT_F1_STATS      } from '../modules/plot_f1_stats'
include { CALCULATE_F1_SCORE } from '../modules/calculate_f1_score'

workflow PROCESS_GFFS {

    take:
        braker_channel
        galba_channel
        metaeuk_channel
        ref_channel

    main:

    // [meta, braker.gft, galba.gtf, metaeuk.gff]
    REFORMAT_GFF(ref_channel.join(braker_channel).join(galba_channel).join(metaeuk_channel))

    // -------- Compare GFFs --------

    gffcompare_input = ref_channel.join(REFORMAT_GFF.out.reformatted).map {meta, ref, b, g, m ->
        def meta_braker = meta.clone()
        meta_braker.tool = "braker"

        def meta_galba = meta.clone()
        meta_galba.tool = "galba"

        def meta_metaeuk = meta.clone()
        meta_metaeuk.tool = "metaeuk"

        return tuple([
            tuple(meta_braker, ref, b),
            tuple(meta_galba, ref, g),
            tuple(meta_metaeuk, ref, m)
        ])
    }.flatMap()

    GFFCOMPARE(gffcompare_input)
    CALCULATE_F1_SCORE(GFFCOMPARE.out.stats)

    f1_channel = CALCULATE_F1_SCORE.out.f1_scores
    .map { meta, path -> path }  
    .collectFile(name: 'combined_f1.stats', newLine: true)

    PLOT_F1_STATS(f1_channel)

    emit:
    reformatted_gffs = REFORMAT_GFF.out.reformatted

}
