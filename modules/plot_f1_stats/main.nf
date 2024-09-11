process PLOT_F1_STATS {

    label 'process_low'

    container "quay.io/microbiome-informatics/microeuks-benchmark-r-scripts:latest"

    input:
    tuple val(meta), path(stats)

    output:
    tuple val(meta), path("f1_stats.pdf")      , emit: f1_plot
    path "versions.yml"                        , emit: versions

    script:
    """
    plot_f1_stats.R $stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$( R --version | head -1 | cut -d' ' -f3 )
    END_VERSIONS
    """
}
