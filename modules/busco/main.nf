process BUSCO {
    label 'process_medium'
    tag "${meta.id}"

    container 'quay.io/biocontainers/busco:5.4.7--pyhdfd78af_0'

    input:
    tuple val(meta), path(fasta)
    path busco_db

    output:
    tuple val(meta), path("short_summary.specific*.txt"), emit: busco_summary
    path "versions.yml"                                 , emit: versions

    script:
    """
    busco  --offline \
            -i ${fasta} \
            -m 'protein' \
            -o out \
            --auto-lineage-euk \
            --download_path ${busco_db} \
            -c ${task.cpus}

    mv out/short_summary.specific*.out.txt "short_summary.specific_${fasta.baseName}.txt"

    // grep completeness
    // value=$(grep 'C:' short_summary.specific.*.${i}.txt | tr '%' '\t' | cut -f2 | tr ':' '\t' | cut -f2);
    // specific=$(basename short_summary.specific.*.${i}.txt);
    // name=$(echo $specific | tr '.' '\t' | cut -f3);
    // echo "${i},${value},metaeuk,${name}" >> stats_tool.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2>&1 | sed 's/^BUSCO //' )
    END_VERSIONS
    """
}
