## Non-Interactive Job Submissions

salloc --mem=10G --time=1:00:00 --cpus-per-task=1
module load fastqc/0.11.9
cd ~/scratch/omics_workshop/preprocessed_data/D2_set01
ls -l *.fastq.gz
fastqc --threads 1 subsampled_R1.fastq.gz

mkdir D3_set01
cd D3_set01/

# Writing script by hand:

vi fastqc_job.sh

############################################
#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=01:00:00

module load fastqc/0.11.9

fastqc --threads 1 ~/scratch/omics_workshop/preprocessed_data/D2_set01/subsampled_R1.fastq.gz
###########################################

# Copy the script:

cp ~/projects/def-sponsor00/Day03/fastqc_job.sh . 


sbatch fastqc_job.sh
squeue
seff $$ # replace $$ with JOBID

sacct -j $$
sacct --starttime today
sacct --starttime $(date -d '3 days ago' +%Y-%m-%d)
sacct -u user01 --starttime today


## Improving Job Efficiency

cd ~/scratch/omics_workshop/preprocessed_data/D3_set01

# Writing script by hand

vi trimmomatic_job.sh

###############################################################
#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=2
# -----------------------------
# Load required modules
# -----------------------------
module load trimmomatic
# -----------------------------
# Define paths and variables
# -----------------------------
INPUT_DIR=/home/user01/scratch/omics_workshop/preprocessed_data/D2_set01
OUTPUT_DIR=/home/user01/scratch/omics_workshop/preprocessed_data/D3_set01
# Move to output directory
cd $OUTPUT_DIR
# -----------------------------
# Run Trimmomatic
# -----------------------------
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 2 \
 $INPUT_DIR/subsampled_R1.fastq.gz $INPUT_DIR/subsampled_R2.fastq.gz \
 subsampled_R1.trim.fastq.gz R1_un.fastq.gz \
 subsampled_R2.trim.fastq.gz R2_un.fastq.gz \
 SLIDINGWINDOW:3:20 MINLEN:50 
###############################################################

# Copy the script

cp ~/projects/def-sponsor00/Day03/trimmomatic_job.sh .


sbatch trimmomatic_job.sh
squeue
sacct -j $$
seff $$

## Implementing Checkpointing for Reliable Computation

cp ~/projects/def-sponsor00/Day03/cp_demo.py ~/scratch/omics_workshop/scripts 
cd ~/scratch/omics_workshop/output_data/
mkdir checkpointing
cd checkpointing
cp ~/projects/def-sponsor00/Day03/cp_job.sh . 
