#!/bin.bash
tree -d; pwd
 
#genome assembly
megahit -1 part1.3/data/culture62/reads.1.fastq.gz -2 part1.3/data/culture62/reads.2.fastq.gz \
--min-contig-len 3000 -m 0.5 -t 2 -o part1.3/exp/megahit_r3

#coverage calculation
coverm contig --coupled part1.3/data/culture62/reads.1.fastq.gz part1.3/data/culture62/reads.2.fastq.gz \
-r part1.3/exp/megahit_r3/final.contigs.fa >> part1.3/exp/coverm_result/coverage_cal.txt

#G+C content calculation
gc.rb part1.3/exp/megahit_r3/final.contigs.fa > part1.3/exp/gc_content/contigs.gc.tsv
