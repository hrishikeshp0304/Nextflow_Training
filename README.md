# Nextflow Training

This workflow script has been written in Nextflow and is designed to take Illumina paired-end reads as input (from an input directory) and perform quality trimming using fastp and genome assembly using SKESA. Further, the workflow splits into two independent parallel operations: assembly quality assessment (QUAST) and genotyping (MLST). 

## Setup

This Nextflow script requires the user to have Nextflow and Docker installed on their terminal. The ``nextflow.config`` file specifies docker biocontainers for each of the four processes involved: fastp, skesa, quast and mlst. The ``main.nf`` file contains the Nextflow script that should be run as follows,
```
./nextflow run main.nf
```

## Recommended Usage

It is recommended to load this repository on [Gitpod](https://gitpod.io/) as a workspace and install Docker and Nextflow as follows,

#### Docker
```
sudo apt-get update
sudo apt-get install docker.io
```
#### Nextflow
```
curl -s https://get.nextflow.io | bash
```

Once these are setup, the above script can simply be run by executing,
```
./nextflow run main.nf
```
