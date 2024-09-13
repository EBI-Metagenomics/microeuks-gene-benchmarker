process BUSCO {
    label 'process_medium'
    tag "${meta.id}"

    container 'quay.io/biocontainers/busco:5.4.7--pyhdfd78af_0'

    input:
    tuple val(meta), path(fasta)
    path busco_db

    output:
    tuple val(meta), path("*specific*.txt"), emit: busco_summary
    path("*stats.txt")                     , emit: busco_stats
    path "versions.yml"                    , emit: versions

    script:
    """
    busco  --offline \
            -i ${fasta} \
            -m 'protein' \
            -o out_${meta.id}_${meta.tool} \
            --auto-lineage-euk \
            --download_path ${busco_db} \
            -c ${task.cpus}

    value=\$(grep 'C:' out_*/short_summary.specific.*.txt | tr '%' '\t' | cut -f2 | tr ':' '\t' | cut -f2)
    specific=\$(basename out_*/short_summary.specific.*.txt)
    name=\$(echo \$specific | tr '.' '\t' | cut -f3)
    echo "${meta.id},\$value,${meta.tool},\$name" > ${meta.id}_${meta.tool}_stats.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2>&1 | sed 's/^BUSCO //' )
    END_VERSIONS
    """

    stub:
    """
    # Create a file with a specific name
    mkdir -p out_test
    touch out_test/short_summary.specific.eukaryota_odb10.AcaCa.txt
    echo "%C:76%" > out_test/short_summary.specific.eukaryota_odb10.AcaCa.txt

    value=\$(grep 'C:' out_*/short_summary.specific.*.txt | tr '%' '\t' | cut -f2 | tr ':' '\t' | cut -f2)

    specific=\$(basename out_*/short_summary.specific.*.txt)

    name=\$(echo \$specific | tr '.' '\t' | cut -f3)

    # Write the extracted values to the stats_tool.txt file
    # output: 76,eukaryota_odb10
    echo "${meta.id},\$value,${meta.tool},\$name" > stats_tool.txt
    """

}
