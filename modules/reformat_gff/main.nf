process REFORMAT_GFF {
    tag '${meta.id}'
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.75':
        'quay.io/biocontainers/biopython:1.75' }"

    input:
    tuple val(meta), path(braker), path(galba), path(metaeuk)

    output:
    tuple val(meta), path("*braker.reformatted.gtf"), path("*galba.reformatted.gtf"), path("*metaeuk.reformatted.gff")   , emit: reformatted
    path "versions.yml"                                                                                                 , emit: versions

    script:
    """
    reformat_gff.py \
                 -s $meta.id \
                 --galba_gtf $galba \
                 --braker_gtf $braker \
                 --metaeuk_gff $metaeuk


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
