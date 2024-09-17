process COUNT_EXONS {

    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.75':
        'quay.io/biocontainers/biopython:1.75' }"

    input:
    tuple val(meta), path(gff_braker), path(gff_galba), path(gff_metaeuk)

    output:
    tuple val(meta), path("*exon_counts_combined.txt")     , emit: exons_table
    path "versions.yml"                                    , emit: versions

    script:
    """
    count_exons.py -o ${meta.id}_exon_counts_combined.txt \
                   $gff_braker $gff_galba $gff_metaeuk

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
