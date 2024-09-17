process CALCULATE_F1_SCORE {
    tag '${meta.id}'
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.75':
        'quay.io/biocontainers/biopython:1.75' }"

    input:
    tuple val(meta), path(stats)

    output:
    tuple val(meta), path("*f1_scores")   , emit: f1_scores
    path "versions.yml"                   , emit: versions

    script:
    """
    calculate_f1_score.py \
                 -s $meta.id \
                 --stats_file $stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import pkg_resources; print(pkg_resources.get_distribution('biopython').version)")
    END_VERSIONS
    """
}
