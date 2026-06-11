
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
I had a quick check with fastqc and the data look ok and free of adapters now:

```
module load FastQC
#Run1:
head -n 1000000 trimmed_kakariki_pool_1_S1_R1_001.fastq > test_trimmed_kakariki_pool_1.fastq
fastqc test_trimmed_kakariki_pool_1.fastq

#Run2:
#head -n 1000000 trimmed_GBS_S1_R1_001.fastq > test_trimmed_GBS.fastq
#fastqc test_trimmed_GBS.fastq

#Run3:
#head -n 1000000 trimmed_kakariki-GBS_S1_R1_001.fastq > test_trimmed_kakariki-GBS.fastq
#fastqc test_trimmed_kakariki-GBS.fastq

#Run4:
#head -n 1000000 trimmed_AAHCWL7M5-9739-P1-00-01_S1_R1_001.fastq > test_trimmed_AAHCWL7M5-9739.fastq
#fastqc test_trimmed_AAHCWL7M5-9739.fastq

```

## Demultiplexing

Copy trimmed data to raw_samples folder.

```
cd raw_samples ## cd raw_samples/run2 ##to seperate the run files to then run demultiplexing on.
ln -s ../source_files/trimmed/trimmed_* . ## ln -s ../../source_files/trimmed/trimmed_GBS_* . ##for when moving into a sub-directory inside the raw_samples folder
cd ..
```
Run demultiplexing

```
module load Stacks/2.52-gimkl-2020a
## NO -q often used for process-radtags gives me an error because of it, but no worries, cutadapatalready took care of this.
##this needs to be run on each run separately
#Run1:
process_radtags -P   -p ../raw_samples/run1/ -o ../samples1/ -b barcodes_LD.txt -e pstI -r -c  --inline-inline

#Run2:
#process_radtags -P   -p ../raw_samples/run2/ -o ../samples2/ -b barcodes_AA.txt -e pstI -r -c  --inline-inline

#Run3:
#process_radtags -P   -p ../raw_samples/run3/ -o ../samples3/ -b barcodes_AA.txt -e pstI -r -c  --inline-inline

#Run4:
#process_radtags -P   -p ../raw_samples/run4/ -o ../samples4/ -b barcodes_SS.txt -e pstI -r -c  --inline-inline

 ```
 Not that good but ok results:
 
 ```
Run 1:
Total Sequences 247360172
Barcode Not Found       40068256        16.2%
Low Quality     5364236 2.2%
RAD Cutsite Not Found   2094249 0.8%
Retained Reads  199833431       80.8%

Run 2:
Total Sequences 86369188
Barcode Not Found       8710318        10.1%
Low Quality     4561831 5.3%
RAD Cutsite Not Found   393975 0.5%
Retained Reads  72703064       84.2%

Run 3:
Total Sequences 130570160
Barcode Not Found       12588536        9.6%
Low Quality     7970 0.0%
RAD Cutsite Not Found   650055 0.5%
Retained Reads  117323599       89.9%

Run 4 (mixed run at OG with two plates of data):
Total Sequences	805388692
Barcode Not Found	212642444     26.4%
Low Quality	4090426 0.5%
RAD Cutsite Not Found	6877748  0.9%
Retained Reads	581778074  72.2%
```
Can run code to look for files with no reads (either script or run within the appropriate samples# folder as code below is doing):
 ```
for f in *.1.fq.gz
do
    sample=$(basename $f .1.fq.gz)
    reads=$(zcat $f | wc -l)
    
    if [ $reads -eq 0 ]
    then
        echo $sample
    fi
done
 ```

3 samples have no reads for run 1:

```
Norfolk_GPE03_3_R
Yellow_CD1888
Yellow_CD1891
```
All samples had reads for runs 2, 3 and 4.

## Merging same samples
This is to merge matching FASTQ files for the same sample to then be aligned (associated with Runs 2+3).

```
set -euo pipefail

src1="../samples2"
src2="../samples3"
out="../merged_samples"

mkdir -p ../merged_samples

logfile="$out/merge_log.txt"
echo "Merge started: $(date)" > "$logfile"

# Get sample names automatically from R1 files
for fq in "$src1"/*.1.fq.gz
do
    sample=$(basename "$fq" .1.fq.gz)

    r1a="$src1/${sample}.1.fq.gz"
    r1b="$src2/${sample}.1.fq.gz"

    r2a="$src1/${sample}.2.fq.gz"
    r2b="$src2/${sample}.2.fq.gz"

    # Check all files exist
    if [[ -f "$r1a" && -f "$r1b" && -f "$r2a" && -f "$r2b" ]]; then

        echo "Merging $sample" | tee -a "$logfile"

        cat "$r1a" "$r1b" > "$out/${sample}.1.fq.gz"
        cat "$r2a" "$r2b" > "$out/${sample}.2.fq.gz"

    else
        echo "WARNING: missing files for $sample" | tee -a "$logfile"
    fi
done

echo "Merge finished: $(date)" >> "$logfile"
```

# Alignment

*This can now be done on any number of runs that have been demultiplexed independently but filtered in the same way*

First we download the genome from:

[https://www.ncbi.nlm.nih.gov/assembly/GCA_025629965.1/](https://www.ncbi.nlm.nih.gov/assembly/GCA_025629965.1/)

Because the reference genome can introduce ascertainment bias, we will work in two rounds. First, we'll call all the SNPs we can, then mask them in all in the reference genome and re-map and call SNPs to avoid biases.


```
mkdir alignment
cd alignment

module load BWA
bwa index GCA_025629965.1_ASM2562996v1_genomic.fna
```


Ludo: Alignment done with [align.sh](align.sh)

Mine: Alignment done with [align_AA.sh](align_AA.sh)

### SNP Calling

Check to see if any samples have too few reads by examining the alignment statistics for each BAM file. Run following within the alignment directory:

```
module load SAMtools
module load BWA

for bam in *.bam
do
    count=$(samtools view -c -F 4 "$bam")
    echo "$bam $count"
done

```

Two norfolk, four yellow, and one Auckland samples have too few reads for refmap and are discarded, creating a popmap.txt without them:

```
Auckland_AuckRCP_12.bam
Norfolk_GPE031_K.bam
Norfolk_GPE033_R.bam
Yellow_CD1888.bam
Yellow_CD1891.bam
Yellow_FT3325.bam
Yellow_FT3310.bam

Antipodean_GE_09.bam --> this sample has 93,804 reads. Have kept it in for now.
```
## Reference mapping pipeline

The  popmap can be created using the stacks help online (https://catchenlab.life.illinois.edu/stacks/manual/) and the barcode files. Assign the samples from different runs, different population numbers (run 1 = batch1, merged runs 2+3 = batch2, run 4 = batch3).

```
#!/bin/sh
 module load Stacks #2.61
 mkdir ../output_refmap
 ref_map.pl --samples ../alignment --popmap ../popmap.txt -T 8  -o ../output_refmap 
```

## Recalling on masked genome to avoid ascertainment bias

Run populations to obtain a VCF (variant call format) and check for low quality samples.
-p = a locus must be present in at least X populations to be retained
-r = within a population, a locus needs to be present in X% of individuals to be considered present in that population (e.g. 10% below)
-R = a locus must be present in X% of individuals across all populations (e.g. 60% below)

```
module load Stacks #2.61

populations \
  -P ../output_refmap/ \
  -M ../popmap.txt \
  -p 3 -r 0.1 -R 0.6 \
  --vcf --structure --plink --treemix \
  -O ../output_refmap/
```
>2,597,201 SNPs remained

Mask them using bedtools to avoid reference bias before realigning:

```
mkdir ../alignment_masked_ref
cd  ../alignment_masked_ref
cp ../alignment/GCA*.fna . #the end . means copy into current directory

module load BEDTools

bedtools maskfasta -fi GCA_025629965.1_ASM2562996v1_genomic.fna  -bed ../output_refmap/populations.snps.vcf -fo GCA_025629965.1_ASM2562996v1_genomic_maskedbysnps.fna
#I used the vcf to check the masked fasta and it does seem to make sense
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
