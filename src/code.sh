#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail
# only proceed if skip != True
if [ $skip == false ]; 
     then
     # Store the bam file name as a string
     bam_file=`dx describe "${input_bam}" --name`

     # Remove .bam extension from bam file name
     bam_prefix="${bam_file%.bam}"

     # Download bam and index files
     dx download "$input_bam" -o "$bam_file"
     dx download "$input_bam_index" -o "${bam_prefix}.bai" 
     
     # download the VCF used by VerifyBAMID from 001
     dx download project-ByfFPz00jy1fk6PjpZ95F27J:file-G77XQY00jy1ZXgBy1fZF7zBQ
     # Create output directory
     mkdir -p out/verifybamid_out/QC/

     # Call verifyBamID for contamination check. The following notable options are passed:
     # --ignoreRG; to check the contamination for the entire BAM rather than examining individual read groups
     # --precise; calculate the likelihood in log-scale for high-depth data (recommended when --maxDepth is greater than 20)
     # --maxDepth 1000; For the targeted exome sequencing, --maxDepth 1000 and --precise is recommended.
     verifyBamID --vcf Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.vcf.gz \
          --bam $bam_file \
          --out out/verifybamid_out/QC/$bam_prefix \
          --verbose --ignoreRG --precise --maxDepth 1000

     # Upload results to DNA Nexus
     dx-upload-all-outputs
fi