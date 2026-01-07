#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

# only proceed if skip != True
if [ "$skip" == false ]; 
     then

     # Store the bam file name as a string
     bam_file=`dx describe "${input_bam}" --name`

     # Remove .bam extension from bam file name
     bam_prefix="${bam_file%.bam}"

     # Download bam and index files
     dx download "$input_bam" -o "/home/dnanexus/$bam_file"
     dx download "$input_bam_index" -o "/home/dnanexus/${bam_prefix}.bai" 

     # Get verifyBAMID_1.1.3 Docker image
     VBID1_DOCKER_IMAGE_LOCATION=project-ByfFPz00jy1fk6PjpZ95F27J:file-J5KPFqj0jy1qJKGxy3V07QYg
     dx download "${VBID1_DOCKER_IMAGE_LOCATION}" -o "/home/dnanexus/verifybamid_1.1.3.tar.gz"
    
    # Extract image name from manifest.json inside tarball
    VBID1_DOCKER_IMAGE_NAME=$(tar xfO /home/dnanexus/verifybamid_1.1.3.tar.gz manifest.json \
        | sed -E 's/.*"RepoTags":\["?([^"]*)".*/\1/')

    echo "Loading Docker image: ${VBID1_DOCKER_IMAGE_NAME}"

    # Load the Docker image
    docker load < /home/dnanexus/verifybamid_1.1.3.tar.gz

    # Remove the .tar to save space
    rm /home/dnanexus/verifybamid_1.1.3.tar.gz

     # Create output directory
     mkdir -p /home/dnanexus/out/verifybamid_out/QC/verifybamid/

     # Call verifyBamID for contamination check. The following notable options are passed:
     # --ignoreRG; to check the contamination for the entire BAM rather than examining individual read groups
     # --precise; calculate the likelihood in log-scale for high-depth data (recommended when --maxDepth is greater than 20)
     # --maxDepth 1000; For the targeted exome sequencing, --maxDepth 1000 and --precise is recommended.
     docker run -v /home/dnanexus:/home/dnanexus \
        --rm "$VBID1_DOCKER_IMAGE_NAME" \
        --vcf /home/dnanexus/Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.vcf.gz \
        --bam /home/dnanexus/$bam_file \
        --out /home/dnanexus/out/verifybamid_out/QC/verifybamid/$bam_prefix \
        --verbose --ignoreRG --precise --maxDepth 1000

     # Upload results to DNA Nexus
     dx-upload-all-outputs
fi