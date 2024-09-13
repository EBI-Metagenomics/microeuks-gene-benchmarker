include { PROCESS_GFFS         } from '../subworkflows/subwf-gff_comparison'
include { PROCESS_EXONS        } from '../subworkflows/subwf-exons'
include { PROCESS_COMPLETENESS } from '../subworkflows/subwf-completeness_estimation'

// ---------------- Notes ----------------

// Input formats GFF/GTF:
// References: all gffs in one folder naming Organism.gff
// MetaEuk:    all gFf in one folder naming Organism.gff
// GALBA:      all gTf in folder Organism/galba.gtf
// BRAKER:     all gTf in folder Organism/galba.gtf

// TODO: for real usage change [-1] in split_braker function to [-2]
// TODO: because format lickly would be Orgamism/GALBA/galba.gft or Orgamism/BRAKER/braker.gft

// ---------------- Notes end -------------

reference_gff = channel.fromPath("tests/data/ref/*.gff")
braker_gtf    = channel.fromPath("tests/data/braker/*/*.gtf")
galba_gtf     = channel.fromPath("tests/data/galba/*/*.gtf")
metaeuk_gff   = channel.fromPath("tests/data/metaeuk/*.gff")

reference_proteins = channel.fromPath("tests/data/ref/*.fa")
braker_proteins    = channel.fromPath("tests/data/braker/*/*.aa")
galba_proteins     = channel.fromPath("tests/data/galba/*/*.aa")
metaeuk_proteins   = channel.fromPath("tests/data/metaeuk/*.fas")

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

    ref_gff_channel = reference_gff.map(split_by_name)
    braker_gtf_channel = braker_gtf.map(split_braker)
    galba_gtf_channel = galba_gtf.map(split_braker)
    metaeuk_gff_channel = metaeuk_gff.map(split_by_name)

    ref_proteins_channel = reference_proteins.map(split_by_name)
    braker_proteins_channel = braker_proteins.map(split_braker)
    galba_proteins_channel = galba_proteins.map(split_braker)
    metaeuk_proteins_channel = metaeuk_proteins.map(split_by_name)

    // -------- GFFs/GTFs --------
    PROCESS_GFFS( braker_gtf_channel, galba_gtf_channel, metaeuk_gff_channel, ref_gff_channel )

    // -------- EXONS --------
    PROCESS_EXONS( PROCESS_GFFS.out.reformatted_gffs )

    // -------- COMPLETENESS ESTIMATION --------
    PROCESS_COMPLETENESS(braker_proteins_channel, galba_proteins_channel, metaeuk_proteins_channel, ref_proteins_channel, params.busco_db)

}