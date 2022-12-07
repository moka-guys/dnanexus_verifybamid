# dnanexus_verifybamid v1.2.0

statgen/verifyBamID [v1.1.3](https://github.com/statgen/verifyBamID/releases/tag/v1.1.3)

## What does this app do?

This app runs verifyBamID to detect sample contamination from population allele frequencies.

verifyBamID models the sequence reads as mixture of two unknown samples based on the allele frequency information in a provided VCF file. Here, the VCF file used is the Omni 2.5M SNP array VCF which contains allele frequency information across individuals from the 1,000 Genomes project (chr20 only). Markers are selected from the VCF where AF >= 0.010000 and callRate >= 0.500000, and contaminated sites are determined based on greater than expected heterozygousity rates.

The required VCF is packaged with the app under resources/home/dnanexus.
See [documentation](https://genome.sph.umich.edu/wiki/VerifyBamID) for further details.

## What are typical use cases for this app?

This app should be executed stand-alone or as part of a DNA Nexus workflow for a single sample.

## What data are required for this app to run?

* Skip - Boolean True/False. If skip == True do not run the tool and no outputs are provided
* BAM file (*.bam)
* BAI file (*bai)

## What does this app output?

The app outputs three files, where [outPrefix] is the bam filename without extension:

1. [outPrefix].selfSM - Per-sample statistics describing how well the sample matches to the annotated sample (tab-delimited file)
2. [outPrefix].depthSM - The depth distribution of the sequence reads per sample (tab-delimited file)
3. [outPrefix].log - verifyBamID log file

The column **freeMix** in the [outPrefix].selfSM file contains the % contamination predicted for the sample (where 0.1=10%).

## How does this app work?

The app runs verifyBamID using an input BAM file and uploads the outputs to DNA Nexus.

## What are the limitations of this app

This app has been verified to run on WES samples only.
verifyBamID will only assess autosomal chromosomes in the input VCF.

## This app was made by Viapath Genome Informatics
