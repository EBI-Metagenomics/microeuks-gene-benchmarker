process PLOT_EXON_COUNTS {

    tag "$meta.id"
    label 'process_low'

    container "quay.io/microbiome-informatics/microeuks-benchmark-python-scripts:latest"

    input:
    tuple val(meta), path(exons_table)

    output:
    tuple val(meta), path("*_plots")             , emit: exons_plots
    path "versions.yml"                          , emit: versions

    script:
    """
    plot_exon_counts.py -i $exons_table -o ${meta.id}_plots

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
