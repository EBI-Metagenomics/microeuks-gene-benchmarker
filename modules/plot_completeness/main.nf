process PLOT_COMPLETENESS {

    tag "$meta.id"
    label 'process_low'

    container "quay.io/microbiome-informatics/microeuks-benchmark-python-scripts:latest"

    input:
    path(table)

    output:
    path("*.png")             , emit: exons_plots
    path "versions.yml"       , emit: versions

    script:
    """
    plot_completeness.py $table

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
