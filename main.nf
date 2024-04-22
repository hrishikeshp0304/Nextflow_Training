params.reads = "$PWD/reads/*_{1,2}.fastq.gz"
params.trimmed_reads = "$PWD/trimming_out"
params.assembly = "$PWD/assembly_out"
params.qa = "$PWD/qa"
params.genotyping = "$PWD/genotyping"

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
    	tuple val(sample_id), path("${sample_id}.fasta")

	// Command to run SKESA
    	script:
    	"""
    	skesa --reads ${trimmed_reads[0]} ${trimmed_reads[1]} --contigs_out ${sample_id}.fasta
    	"""
}

// Check if qa dir exists, if not create it
if (!file(params.qa).exists()) {
        file(params.qa).mkdirs()
}

// Quality Assessment process
process quast {
     	// Write the output to the qa directory
    	publishDir params.qa, mode: 'copy'

    	input:
    	tuple val(sample_id), path(assembly_file)

    	output:
    	path("quast_results_${sample_id}") 
    
    	script:
    	"""
    	quast.py ${assembly_file} -o quast_results_${sample_id}
   	"""
}

// Check if genotyping dir exists, if not create it
if (!file(params.genotyping).exists()) {
        file(params.genotyping).mkdirs()
}

// MLST Report process
process mlst {
    	// Write the output to the genotyping directory
    	publishDir params.genotyping, mode: 'copy'

    	input:
    	tuple val(sample_id), path(assembly_file)

    	output:
    	path("mlst_results_${sample_id}")

    	script:
    	"""
    	mlst ${assembly_file} > mlst_results_${sample_id}
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

	// Perform quast and pass the output to a new channel quast_ch
   	quast_ch = quast(assembly_ch)

    	// Perform mlst and pass the output to a new channel mlst_ch
   	mlst_ch = mlst(assembly_ch)
}
