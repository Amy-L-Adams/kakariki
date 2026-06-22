Phylogenetics
We did a phylogenetic analysis using IQTREE.

First , I convert the SNPs to a phylogenetic input format for IQtree: phylip, using vcf2phylip [https://github.com/edgardomortiz/vcf2phylip
](https://github.com/edgardomortiz/vcf2phylip/blob/master/vcf2phylip.py). From within the scripts directory run following command in terminal:
```
python3 ./vcf2phylip.py --input output_refmap_masked_batches2_SNPfiltering/kakariki205indv177800SNPs.vcf
```

Then I run IQtree using my own conda environment, the GTR+G model with 1000 bootstraps.

```
module load IQ-TREE/3.1.1-foss-2023a
iqtree3 -nt 16 -s kakariki205indv177800SNPs.min4.phy -st DNA -m GTR+G -bb 1000  -pre inferred
```
