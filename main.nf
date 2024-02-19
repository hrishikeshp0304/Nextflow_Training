params.reads = "$PWD/reads/*_R{1,2}.fq.gz"

process fastp {
	input:
	tuple val(sample_id), path(reads)

	output:
	tuple path("trimmed_reads/${sample_id}_R1_trimmed.fq.gz"), path("trimmed_reads/${sample_id}_R2_trimmed.fq.gz")

	script:
	"""
	mkdir trimmed_reads
	fastp --in1 ${reads[0]} --in2 ${reads[1]} --out1 trimmed_reads/${sample_id}_R1_trimmed.fq.gz --out2 trimmed_reads/${sample_id}_R2_trimmed.fq.gz
	"""
}

process skesa {
        input:
        tuple path(forward_trimmed_read), path(reverse_trimmed_read)

        output:
        path "final_assembly/contigs.fna"

        script:
        """
        mkdir final_assembly
        skesa --reads ${forward_trimmed_read} ${reverse_trimmed_read} --contigs_out final_assembly/contigs.fna
        """
}

workflow {
	reads_ch = Channel.fromFilePairs(params.reads)
	trimmed_ch = fastp(reads_ch)
	assembly_ch = skesa(trimmed_ch)
}
