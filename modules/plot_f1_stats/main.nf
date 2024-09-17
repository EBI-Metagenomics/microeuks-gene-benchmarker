process PLOT_F1_STATS {
    tag '${meta.id}'
    label 'process_low'

    container "quay.io/microbiome-informatics/microeuks-benchmark-python-scripts:latest"

    input:
    path(stats)

    output:
    path("f1_stats.pdf")      , emit: f1_plot
    path "versions.yml"       , emit: versions

    script:
    """
    plot_f1_stats.py $stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}

