# Nextflow Training

This workflow script has been written in Nextflow and is designed to take Illumina paired-end reads as input (from an input directory) and perform quality trimming using fastp and finally, output a genome assembly using SKESA. 

## Setup

This Nextflow script requires the user to have Nextflow and Docker installed on their terminal. The ``nextflow.config`` file specifies docker biocontainers for each of the two processes involved: fastp and skesa. The ``main.nf`` file contains the Nextflow script that should be run as follows,
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
