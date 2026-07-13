# SNP calling

*From here to alignment, things need to be done in different foldewrs for different runs*

First, I create a folder for the source files and folders to run Stacks, raw (which will contain the trimmed data) and samples.

```
mkdir source_files raw samples
cd source_files
zcat kakariki_pool_1_S1_R1_001.fastq.gz | head -n 1000000 > test.fastq
module load FastQC
fastqc test.fastq # Tells you adapter and read length.
```
## Adapter trimming

Trimming off adapters and removing reads shorter than 50bp with cutadapt.


```
cd source_files
cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_kakariki_pool_1_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_kakariki_pool_1_S1_R2_001.fastq kakariki_pool_1_S1_R1_001.fastq.gz  kakariki_pool_1_S1_R2_001.fastq.gz
cd ..
```
I had a quick check with fastqc and the data look ok and free of adapters now.
