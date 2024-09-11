process PROCESS_EXONS {

    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.75':
        'quay.io/biocontainers/biopython:1.75' }"

    input:
    tuple val(meta), path(gffs)

    output:
    path("exon_counts_combined.txt")     , emit: exons_table
    path("exon_plots")                   , emit: exons_plots
    path "versions.yml"                  , emit: versions

    script:
    """
    count_exons.py $gffs

    plot_exon_counts.py -i plot_exon_counts.py -o exon_plots

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
