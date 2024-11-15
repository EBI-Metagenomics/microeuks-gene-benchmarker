process GFFCOMPARE {
    tag "$meta.id $meta.tool"
    label 'process_low'

    container 'quay.io/biocontainers/gffcompare:0.12.6--h4ac6f70_3'

    input:
    tuple val(meta), path(ref_gff), path(tool_gff)

    output:
    tuple val(meta), path("*.stats")         , emit: stats
    path "versions.yml"                      , emit: versions

    script:
    """
    gffcompare -r $ref_gff -o "${meta.id}_${meta.tool}" $tool_gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gffcompare: \$(gffcompare --version 2>&1 | tr ' ' '\t' | cut -f2)
    END_VERSIONS
    """
}
