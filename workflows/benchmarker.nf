include { REFORMAT_GFF } from '../modules/reformat_gff'
include { GFFCOMPARE } from '../modules/gffcompare'
// ---------------- Notes ----------------

// Input formats:
// References: all gffs in one folder naming Organism.gff
// MetaEuk:    all gFf in one folder naming Organism.gff
// GALBA:      all gTf in folder Organism/galba.gtf
// BRAKER:     all gTf in folder Organism/galba.gtf

// TODO: for real usage change [-1] in split_braker function to [-2]
// TODO: because format lickly would be Orgamism/GALBA/galba.gft or Orgamism/BRAKER/braker.gft

// ---------------- Notes end -------------

reference_gff = channel.fromPath("tests/data/ref/*")
braker = channel.fromPath("tests/data/braker/*/*")
galba = channel.fromPath("tests/data/galba/*/*")
metaeuk = channel.fromPath("tests/data/metaeuk/*")

workflow BENCHMARKER {

    def split_by_name = { file ->
        def meta = [];
        def name = file.baseName;
        meta = ["id": name];
        return tuple(meta, file);
    }
    def split_braker = { file ->
        def meta = [];
        def name = file.parent.toString().split('/')[-1];
        meta = ["id": name];
        return tuple(meta, file);
    }

    ref_channel = reference_gff.map(split_by_name)
    braker_channel = braker.map(split_braker)
    galba_channel = galba.map(split_braker)
    metaeuk_channel = metaeuk.map(split_by_name)

    // [meta, braker.gft, galba.gtf, metaeuk.gff]
    REFORMAT_GFF(braker_channel.join(galba_channel).join(metaeuk_channel))

    gffcompare_input = ref_channel.join(REFORMAT_GFF.out.reformatted).map {meta, ref, b, g, m ->
        return tuple([
            tuple(meta, ref, b),
            tuple(meta, ref, g),
            tuple(meta, ref, m)
        ])
    }.flatMap()
    GFFCOMPARE(gffcompare_input)

}