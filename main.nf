// Define parameters and their default paths. These can be set on the command-line (with priority) as well.
params.reads = "$PWD/reads/*_R{1,2}.fq.gz"
params.trimmed_reads = "$PWD/trimming_out"
params.assembly = "$PWD/assembly_out"

// Check if trimmed_out dir exists. Create, if doesnt exist.
if (!file(params.trimmed_reads).exists()) {
    file(params.trimmed_reads).mkdirs()
}

// Process to run fastp for read quality trimming and filtering
process fastp {

	// Write the output to the trimming_out directory
	publishDir params.trimmed_reads, mode:'copy'
	
	// Define the input to this process
	input:
	tuple val(sample_id), path(reads)

	// Define the output files from this process
	output:
	tuple val(sample_id), path("${sample_id}_{1,2}_trimmed.fq.gz")

	// Command to run fastp
	script:
	"""
	fastp --in1 ${reads[0]} --in2 ${reads[1]} --out1 ${sample_id}_1_trimmed.fq.gz --out2 ${sample_id}_2_trimmed.fq.gz
	"""
}

// Check if assembly_out dir exists, if not create it
if (!file(params.assembly).exists()) {
    file(params.assembly).mkdirs()
}

// Process to run SKESA for genome assembly
process skesa {

	// Write the output to the assembly_out directory
    publishDir params.assembly, mode:'copy'

	// Trimmed input files
    input:
    tuple val(sample_id), path(trimmed_reads)

	// Output assembly files from this process
    output:
    path("${sample_id}".fasta)

	// Command to run SKESA
    script:
    """
    skesa --reads ${trimmed_reads[0]} ${trimmed_reads[1]} --contigs_out ${sample_id}.fasta
    """
}

// Define the workflow
workflow {
	//Define input reads channel for taking raw reads from the parameter params.reads
	reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	//Perform trimming and pass the output to a new channel trimmed_ch 
	trimmed_ch = fastp(reads_ch)

	//Perform assembly and pass the output to a new channel assembly_ch
	assembly_ch = skesa(trimmed_ch)
}
