#!/bin/bash

# This script builds the impc-ontology-pipeline on the singularity cluster.
# Once the artifact is built, it must be copied to a permanent place for use.

# mphp is the directory where the build is to be executed. For singularity,
# mphp must me visible in the file system. To check file system visibility,
# run this command (it's an interactive shell) and do a df to make sure the directories you expect are mounted.
#     singularity shell docker://obolibrary/odkfull:latest
# To build this project by hand, execute the following steps:
# 1. Get an interactive lsf cluster shell with the docker image:
#     bsub -Is -M 12G -R "rusage[mem=12G]" singularity shell docker://obolibrary/odkfull:latest
# 2. From the bsub shell created above:
#    A. Execute the statements below between 'export mphp...' and 'cd impc-ontology-pipeline' (inclusive).
#    B. Make impc_ontologies -B
export mphp=/nfs/public/rw/homes/tc_mi01/mphp
export pipeline=$mphp/impc-ontology-pipeline
export ROBOT_JAVA_ARGS='-Xmx12G'
cd $mphp
echo "rm -rf $pipeline"
rm -rf $pipeline
git clone https://github.com/mpi2/impc-ontology-pipeline.git impc-ontology-pipeline
cd impc-ontology-pipeline

#singularity pull docker://obolibrary/odkfull
singularity pull shub://obolibrary/odkfull
singularity exec --pwd $pipeline docker://obolibrary/odkfull make impc_ontologies -B

# Command to submit the job to the singularity cluster:
# bsub -M 12G -R "rusage[mem=12G]" -o work.out -e work.err /nfs/public/rw/homes/tc_mi01/mphp/pipeline.sh
