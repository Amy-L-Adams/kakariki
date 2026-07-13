# SNP list

Create a list of SNPs from within the GBS dataset

```
grep -v “#” yourvcf.vcf | cut -f 1,2 > snp.lst

```
Extract these SNPs from the genomic (museum) data using XXXX:

# SNP calling

*From here to alignment, things need to be done in different folders for different runs*

First, I create a folder for the source files and folders to run Stacks, raw (which will contain the trimmed data) and samples.

```
mkdir source_files raw_samples  ##makes 2 new folders
cd source_files
module load FastQC

#Run1:
zcat kakariki_pool_1_S1_R1_001.fastq.gz | head -n 1000000 > kakariki_pool_1.fastq ##creates a fastq file
fastqc kakariki_pool_1.fastq # Generates a report. Tells you adapter and read lengths.

#Run2:
## zcat GBS_S1_R1_001.fastq.gz | head -n 1000000 > GBS_R1.fastq
## fastqc GBS_R1.fastq

#Run3:
## zcat Kakariki-GBS_S1_R1_001.fastq.gz | head -n 1000000 > Kakariki-GBS_R1.fastq 
## fastqc Kakariki-GBS_R1.fastq

#Run4:
## zcat AAHCWL7M5-9739-P1-00-01_S1_L001_R1_001.fastq.gz | head -n 1000000 > AAHCWL7M5_R1.fastq
## fastqc AAHCWL7M5_R1.fastq

```
## Adapter trimming

Trimming off adapters and removing reads shorter than 50bp with cutadapt. Need to complete this for each pair of sequencing runs.
