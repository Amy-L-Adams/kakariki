
# Kakariki data structure

Run 1: Ludo, Australia, file prefix = kakariki_pool_1

Run 2: Amy, Australia, file prefix = GBS (same samples as run 3)

Run 3: Amy, Australia, file prefix = Kakariki-GBS (same samples as run 2)

Run 4 (2 x mixed plates): Shanshan, OG Dunedin, file prefix = AAHCWL7M5-9739-P1-00-01

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


```
cd source_files
module load cutadapt
#Run1:
cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_kakariki_pool_1_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_kakariki_pool_1_S1_R2_001.fastq kakariki_pool_1_S1_R1_001.fastq.gz kakariki_pool_1_S1_R2_001.fastq.gz  #### these are the Illumina universal adapters. NB that this is only partial sequence which is often fine as cutadapt can detect partial matches and shorter adapter seeds often used.

#Run2:
#cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_GBS_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_GBS_S1_R2_001.fastq GBS_S1_R1_001.fastq.gz GBS_S1_R2_001.fastq.gz

#Run3:
#cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_kakariki-GBS_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_kakariki-GBS_S1_R2_001.fastq Kakariki-GBS_S1_R1_001.fastq.gz Kakariki-GBS_S1_R2_001.fastq.gz

#Run4:
#cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_AAHCWL7M5-9739-P1-00-01_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_AAHCWL7M5-9739-P1-00-01_S1_R2_001.fastq AAHCWL7M5-9739-P1-00-01_S1_L001_R1_001.fastq.gz AAHCWL7M5-9739-P1-00-01_S1_L001_R2_001.fastq.gz
cd ..
```


```
### XX

cc

```
cc

```

cc

```
cc
```
