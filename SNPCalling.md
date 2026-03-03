# SNP calling

*From here to alignment, things need to be done in different foldewrs for different runs*

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
cutadapt  -j 8 -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -q 25 -o trimmed_kakariki_pool_1_S1_R1_001.fastq --minimum-length 50:50   -p  trimmed_kakariki_pool_1_S1_R2_001.fastq kakariki_pool_1_S1_R1_001.fastq.gz  kakariki_pool_1_S1_R2_001.fastq.gz
cd ..
```
I had a quick check with fastqc and the data look ok and free of adapters now.

## Demultiplexing



Copy trimmed data to raw folder.

```
cd raw
ln -s ../source_files/trimmed_ka* .
cd ..
```
Run demultiplexing

```
module load Stacks/2.52-gimkl-2020a
process_radtags -P   -p raw/ -o ./samples/ -b barcodes.txt -e pstI -r -c  --inline-inline # NO -q often used for process-radtags gives me an error because of it, but no worries, cutadapatalready took care of this
 ```
 Not that good but ok results:
 
 ```
Total Sequences 247360172
Barcode Not Found       40068256        16.2%
Low Quality     5364236 2.2%
RAD Cutsite Not Found   2094249 0.8%
Retained Reads  199833431       80.8%
```
3 samples have no reads:

```
Norfolk_GPE033_R
Yellow_CD1887
Yellow_CD1888
```


# Alignment

*This can now be done on any number of run that have been demultiplexed independently but filtered the same way*

First we download the genome from:

[https://www.ncbi.nlm.nih.gov/assembly/GCA_025629965.1/](https://www.ncbi.nlm.nih.gov/assembly/GCA_025629965.1/)

Because the reference genome can introduce ascertainment bias, we will work in two rounds. First, we'll call all the SNPs we can, then mask them in all in the reference genome and re-map and call SNPs to avoid biases.


```
mkdir alignment
cd alignment

module load BWA
bwa index GCA_025629965.1_ASM2562996v1_genomic.fna
```


Alignment done with [align.sh](align.sh)

### SNP Calling

2 norfolk and two yellow samples samples have too few reads for refmap and are discarded, creating a popmap.txt without them:

```
Norfolk_GPE031_K.bam
Norfolk_GPE033_R.bam
Yellow_CD1887
Yellow_CD1888
```
```
#!/bin/sh
 module load Stacks #2.61
 mkdir output_refmap
 ref_map.pl --samples alignment --popmap popmap.txt -T 8  -o output_refmap 
```

The  popmap can be created using the stacks help online and the barcodes file in this repository metadata. 

## Recalling on masked genome to avoid ascertainment bias

I run populations again to obtain a VCF and check for low quality samples.

```
populations -P output_refmap/ -M popmap.txt  --vcf --structure --plink --treemix -O output_refmap #no R because we want all possible variants to mask
```
>2.75 mio SNPs remained

Mask them using bedtools to avoid reference bias before realigning:

```
mkdir alignment_masked_ref
cd  alignment_masked_ref
cp ../alignment/GCA*.fna .

module load BEDTools
bedtools maskfasta
bedtools maskfasta -fi GCA_025629965.1_ASM2562996v1_genomic.fna  -bed ../output_refmap/populations.snps.vcf -fo GCA_025629965.1_ASM2562996v1_genomic_maskedbysnps.fna
#I used the vcf to check the masked fasta and it does seem to make
```

GCA_025629965.1_ASM2562996v1_genomic_maskedbysnps.fna is masked

redo the aligment on this one:

```
module load BWA
bwa index GCA_025629965.1_ASM2562996v1_genomic_maskedbysnps.fna
```

The alignment is done with [alignment_masked.sh](alignment_masked.sh) (which is just changing reference genome from  



```
 module load Stacks 
 mkdir output_refmap_masked
 ref_map.pl --samples alignment_masked_ref --popmap popmap.txt -T 8  -o output_refmap_masked/ 
```

Populations with low filtering
```
populations -P output_refmap_masked/ -M popmap.txt  --vcf --structure --plink --treemix   -O output_refmap_masked/ -R 0.2 # remove snps with less than 20% individuals having any info
```

## SNP filtering


First I do  quick check for individuals with LOTS AND LOTS of missing data.

```
vcftools --vcf output_refmap_masked/populations.snps.vcf --missing-indv # or indv-missing
```

the output is the file out.imiss

One individuals with loads of missing data:

```
Yellow_FT3310   715525  0       708453  0.990116
```
I remove it from the popmap and re-run populations without filters:

```
populations -P output_refmap_masked/ -M popmap.txt  --vcf --structure --plink --treemix   -O output_refmap_masked/
```


I filter it using:

```
vcftools --vcf populations.snps.vcf --max-missing 0.8 --thin 100 --recode ## remove stuff found in les than 80% of individuals AND the thin is within 100bp of each other
```

After filtering, kept 89 out of 89 Individuals
After filtering, kept 78997 out of a possible 78997 Sites
Run Time = 1.00 seconds

Can always have a check to se if there are terrible individuals left here:

First I do  quick check for individuals with LOTS AND LOTS of missing data.

```
vcftools --vcf output_refmap_masked/populations.snps.vcf --missing-indv # or indv-missing
```

Here I usually rename the file something usefile because it is now out.recode.vcf

```
mv out.recode.vcf kakarikiXXXindvXXXXSNPsxxxmaxmiss.vcf
```
