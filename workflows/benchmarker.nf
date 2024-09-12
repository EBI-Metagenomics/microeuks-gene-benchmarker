include { PROCESS_GFFS } from '../subworkflows/subwf-gff_comparison'
include { PROCESS_EXONS } from '../subworkflows/subwf-exons'

// ---------------- Notes ----------------

// Input formats:
// References: all gffs in one folder naming Organism.gff
// MetaEuk:    all gFf in one folder naming Organism.gff
// GALBA:      all gTf in folder Organism/galba.gtf
// BRAKER:     all gTf in folder Organism/galba.gtf

// TODO: for real usage change [-1] in split_braker function to [-2]
// TODO: because format lickly would be Orgamism/GALBA/galba.gft or Orgamism/BRAKER/braker.gft

// ---------------- Notes end -------------

reference_gff = channel.fromPath("tests/data/ref/*.gff")
braker = channel.fromPath("tests/data/braker/*/*.gtf")
galba = channel.fromPath("tests/data/galba/*/*.gtf")
metaeuk = channel.fromPath("tests/data/metaeuk/*.gff")

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

    // -------- GFFs/GTFs --------
    PROCESS_GFFS( braker_channel, galba_channel, metaeuk_channel, ref_channel )

    // -------- Exons --------
    PROCESS_EXONS( PROCESS_GFFS.out.reformatted_gffs )

}