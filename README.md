# dnanexus_verifybamid v1.2.2

statgen/verifyBamID [v1.1.3](https://github.com/statgen/verifyBamID/releases/tag/v1.1.3)

## What does this app do?

This app runs verifyBamID to detect sample contamination by comparing sample genotype to population allele frequencies.

This contamination estimate is calculated using a likelihood-based mixture model that compares observed allele counts from sequence reads to expected genotype probabilities derived from the population allele frequency provided in the reference VCF. The likelihoods of each read being obtained from the intended sample or from another sample via contamination are used to calculate the sequence-only contamination estimate value **FREEMIX**.

Here, the VCF file used is the Omni 2.5M SNP array VCF which contains allele frequency information across individuals from the 1,000 Genomes project (chr20 only, to reduce the compute time of verifyBamID). Markers are selected from the VCF where AF >= 0.010000 and callRate >= 0.500000.

This app utilises a Docker container to run the verifyBamID executable, which is available in the moka-guys seglh_verifybamid_docker repository as well as the GSTT DNAnexus project 001_ToolsReferenceData/Docker.

The required VCF is packaged with the app under resources/home/dnanexus.

See [documentation](https://genome.sph.umich.edu/wiki/VerifyBamID) for further details.

## What are typical use cases for this app?

verifyBamID is used as a quality control metric to detect contamination or sample swaps. This app should be executed stand-alone or as part of a DNA Nexus workflow for a single sample.
Analysis using verifyBamID is supported by the MultiQC plugin for integration into QC workflows. 

## What data are required for this app to run?

* Skip - Boolean True/False. If skip == True do not run the tool and no outputs are provided
* BAM file (*.bam)
* BAI file (*bai)

## What does this app output?

The app outputs three files, where [outPrefix] is the bam filename without extension:

1. [outPrefix].selfSM - Per-sample statistics describing how well the sample matches to the annotated sample (tab-delimited file)
2. [outPrefix].depthSM - The depth distribution of the sequence reads per sample (tab-delimited file)
3. [outPrefix].log - verifyBamID log file

The column **FREEMIX** in the [outPrefix].selfSM file contains the % contamination predicted for the sample (where 0.1=10%). This value is reported as a percentage by MultiQC under the General Statistics table as **Contamination (S)**.

## How does this app work?

The app runs verifyBamID using an input BAM file and uploads the outputs to DNA Nexus under /QC/verifybamid.

## What are the limitations of this app?

verifyBamID will only assess autosomal chromosomes in the input VCF.

The authors of verifyBamID [recommend](https://pmc.ncbi.nlm.nih.gov/articles/PMC3487130/) that the population allele frequencies provided in the VCF are matched to the sample ancestry to reduce bias in the contamination estimate. However, for use in clinical pipelines where sample ancestry data are not available or too time-consuming to incorporate into the workflow, this app uses the same allele frequencies for every estimate, which may reduce accuracy in the contamination estimate for some samples not well-represented in the VCF.

## This app was made by Synnovis Clinical Bioinformatics