# SNP calling

First, I create a folder for the source files and folders to run Stacks, raw (which will contain the trimmed data) and samples. raw2 and samples 2 are for the samples that were on Gracie's lane.

```
mkdir source_files raw samples raw2 samples2
cd source_files
zcat kakariki_pool_1_S1_R1_001.fastq.gz | head -n 1000000 > test.fastq
module load FastQC
fastqc test.fastq # Looks okay
```
## Adapter trimming

Trimming off adapters and removing reads shorter than 50bp with cutadapt.


```
cd source_files
cutadapt -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_GK_GM_S1_R2_001.fastq --minimum-length 50:50   -p  trimmed_kakariki_pool_1_S1_R2_001.fastq kakariki_pool_1_S1_R1_001.fastq.gz  kakariki_pool_1_S1_R2_001.fastq.gz
cd ..
```
I had a quick check with fastqc and the data look ok and free of adapters now.

## Demultiplexing


###  Steven's lane

Copy trimmed data to raw folder.

```
cd raw
ln -s ../source_files/trimmed_SN* .
cd ..
```
Run demultiplexing

```
module load Stacks/2.52-gimkl-2020a
process_radtags -P   -p raw/ -o ./samples/ -b barcodes.txt -e pstI -r -c  --inline-inline # NO -q often used for process-radtags gives me an error because of it, but no worries, cutadapatalready took care of this
 ```
 Good results:
 
 ```
228528076 total sequences
 19710844 barcode not found drops (8.6%)
   105160 low quality read drops (0.0%)
  2102959 RAD cutsite not found drops (0.9%)
206609113 retained reads (90.4%)
```

### Gracie's lane

Copy trimmed data to raw folder.

```
mkdir raw2 samples2
cd raw2
ln -s ../source_files/trimmed_GK* .
cd ..
```
Run demultiplexing


```
module load Stacks # 2.61
process_radtags -P   -p raw2/ -o ./samples2/ -b barcodes_gracie.txt -e pstI -r -c  --inline-inline # NO -q process-radtags gives me an error because of it, but no worries, cutadapatalready took care of this
 ```


# Alignment

```
mkdir alignment
cd alignment

## Copy in stoneflygenomeassemblyv1.fasta

module load BWA
bwa index stoneflygenomeassemblyv1.fasta
```
create a folder with all the samples we need.

```
mkdir samples_all 
cd samples_all
ln -s ../samples/* .
ln -s samples2/* .
```

Cleaning the 3'end of short forward and reverse:

```
python Clean3pAdapteronShortDemuxReads.py samples_all samples_clean
```


Alignment done with align.sh

### SNP Calling

```
#!/bin/sh
 module load Stacks #2.61
 mkdir output_refmap
 ref_map.pl --samples alignment --popmap popmap_clean.txt -T 8  -o output_refmap 
```

The  popmap can be created using the stacks help online and the barcodes file in this repository metadata. A cleaned popmap without the problematic samples can be found in the metadata folder: [metadata/popmap_clean.txt]( metadata/popmap_clean.txt)

7 samples have too few reads and make Stacks bug:  "Mn_25y"    "Mb_28n"    "Fg_105y"   "Lee2a_13n" "bj_23"     "bj_24"   "jim_19". I tried remapping them, and they did indeed have too few reads after demultiplexing.

I run populations again to obtain a VCF and check for low quality samples.

```
populations -P output_refmap/ -M popmap.txt  --vcf --structure --plink --treemix --max-obs-het 0.65 -R 0.75  -O output_refmap
```
82953 variants remained.

```
module load VCFtools 
vcftools --vcf output_refmap/populations.snps.vcf --missing-indv
``` 

The following samples are problematic:

```
Mn_6n	82953	0	65375	0.788097
Gilf48v2y	82953	0	65921	0.794679
Jim64y	82953	0	80127	0.965933
Mepass_2y	82953	0	80893	0.975167
Mim591y	82953	0	80930	0.975613
Owaka16y	82953	0	81183	0.978663
bj_18	82953	0	81526	0.982797
Fg_30n	82953	0	81996	0.988463
Matai32y	82953	0	82618	0.995962
Owaka3n	82953	0	82621	0.995998
Fg_96y	82953	0	82739	0.99742
```
Remove them from the popmap. Added to the other samples we now miss 19 samples.

```
grep -Ev "^Mn_6n\\s|^Gilf48v2y\\s|^Jim64y\\s|^Mepass_2y\\s|^Mim591y\\s|^Owaka16y\\s|^bj_18\\s|^Fg_30n\\s|^Owaka3n\\s|^Matai32y\\s|^Fg_96y\\s" popmap.txt > popmap_clean.txt```
```

```
populations -P output_refmap/ -M popmap_clean.txt  --vcf --structure --plink --treemix --max-obs-het 0.65 -R 0.8  -O output_refmap
```

78360 variants remained for 221 samples (-R 0.8)

The vcf is too big to fit in this repository but it can be found at [this link](https://drive.google.com/file/d/19MqCXvTZwpHR0lUj4HwxERqWKFp9jMRO/view?usp=sharing)
