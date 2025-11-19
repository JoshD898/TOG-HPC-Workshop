# If needed, download the metadata from here: https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=2&WebEnv=MCID_691e0e098ec75fd32c2b02c2&o=acc_s%3Aa

## Transfer Metadata

# Windows
scp SraRunTable.csv user$$@omics.c3.ca:/home/user$$/scratch/omics_workshop/input_data/metadata/metadata_02/

# Mac/Linux
rsync -avx SraRunTable.csv user$$@omics.c3.ca:/home/user$$/scratch/omics_workshop/input_data/metadata/metadata_02/

ls -l ~/scratch/omics_workshop/input_data/metadata/metadata_02

## Allocate Compute Resources

salloc --mem=10G --time=1:00:00 --nodes=1 --cpus-per-task=1 

## Navigate to Raw Data Directory

cd ~/scratch/omics_workshop/input_data/raw_data/raw_data_02

## Understand FASTQ Format

head -n 4 SRR25110243_1.fastq 


## Sub-sampling Reads using SeqKit

module load seqkit
cd ~/scratch/omics_workshop/preprocessed_data
mkdir D2_set01
cd D2_set01

seqkit sample -p 0.10 -s 2025 ~/scratch/omics_workshop/input_data/raw_data/raw_data_02/SRR25110243_1.fastq -o subsampled_R1.fastq.gz & 
seqkit sample -p 0.10 -s 2025 ~/scratch/omics_workshop/input_data/raw_data/raw_data_02/SRR25110243_2.fastq -o subsampled_R2.fastq.gz & 

ls -l ~/scratch/omics_workshop/input_data/raw_data/raw_data_02/SRR25110243_1.fastq
pwd
ls -l subsampled_R1.fastq.gz

seqkit stat subsampled_R1.fastq.gz
seqkit stat subsampled_R2.fastq.gz

## Quality Assessment with FastQC

module spider fastqc
module spider fastqc/0.11.9
module load StdEnv/2020
module load fastqc/0.11.9

fastqc -h

fastqc --threads 1 subsampled_R1.fastq.gz

unzip subsampled_R1_fastqc.zip 
unzip subsampled_R2_fastqc.zip

cd subsampled_R1_fastqc
less summary.txt

## Preprocessing step to filter the low quality reads?

salloc --mem=10G --time=1:00:00
module load trimmomatic
pwd
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE subsampled_R1.fastq.gz subsampled_R2.fastq.gz subsampled_R1.trim.fastq.gz R1_un.fastq.gz subsampled_R2.trim.fastq.gz R2_un.fastq.gz SLIDINGWINDOW:3:20 MINLEN:50 

salloc --mem=10G --time=1:00:00 --cpus-per-task=2
module load trimmomatic 
time java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 2 subsampled_R1.fastq.gz subsampled_R2.fastq.gz subsampled_R1.trim.fastq.gz R1_un.fastq.gz subsampled_R2.trim.fastq.gz R2_un.fastq.gz SLIDINGWINDOW:3:20 MINLEN:50 

## Indexing the reference genome
cd ~/scratch/omics_workshop/input_data
mkdir refgenome
cd refgenome

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/052/857/255/GCA_052857255.1_ASM5285725v1/GCA_052857255.1_ASM5285725v1_genomic.fna.gz

module load bwa

bwa index GCA_052857255.1_ASM5285725v1_genomic.fna.gz

# If needed, pre-indexed genome is here: ~/projects/def-sponsor00/Day02/refgenome 

## Aligning Reads to the Reference Genome

cd ~/scratch/omics_workshop/output_data
salloc --mem=10G --cpus-per-task=2 --time=2:00:00

module load bwa
bwa mem -t 2 ~/projects/def-sponsor00/Day02/refgenome/GCA_052857255.1_ASM5285725v1_genomic.fna.gz ~/scratch/omics_workshop/preprocessed_data/D2_set01/subsampled_R1.fastq.gz ~/scratch/omics_workshop/preprocessed_data/D2_set01/subsampled_R2.fastq.gz > subsampled_out.sam & 

## Understanding the Alignment Section (SAM / BAM File Format) 

less subsampled_out.sam

module load samtools
samtools view -S -b subsampled_out.sam > subsampled_out.bam

samtools flagstat subsampled_out.bam
