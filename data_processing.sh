
#!/bin/bash
#all directories have been pre-create first

pwd; tree -d;
#dataQC
#FastQC for each file in shotgun_data
FILES="part1.2/data_1.2/shotgun_data/*.fastq.gz"
for f in $FILES
do
       echo "Processing FastQC for $f file";
       fastqc -o part1.2/exp/FastQC/ $f;
done
#trimming: the fastqc showed ever good read result with high quality bases no need to trim

cd part1.2/exp/mapping/; #move to mapping directory
#reads mapping and extract unmapped reads
#loop through samples
for f in S13 S14
do
        echo "Mapping file $f";
        #read mapping to ref genome then save as BAM file: we have over 20 million reads in 1 sample,
       #using 10 threads increase the speedrun 
        bwa mem -t 10 ../../data_1.2/index_files/GCA_014282415.2.fa \
        ../../data_1.2/shotgun_data/${f}_R1.fastq.gz ../../data_1.2/shotgun_data/${f}_R2.fastq.gz \
        | samtools view -bS - > ${f}.bam

        #extract unmapped reads and transform into fastq file
        samtools view -b -f 12 -F 256 -F 2048 ${f}.bam \
        | bamToFastq -i /dev/stdin -fq ${f}_R1_nonhost.fastq -fq2 ${f}_R2_nonhost.fastq;

        #gun zip files to reduce storage space
        gzip ${f}_R1_nonhost.fastq;
        gzip ${f}_R2_nonhost.fastq;

        #counting reads
        #count unmapped reads in BAm file with same filter with extraction
        MICROBE=$(samtools view -c -f 12 -F 256 -F 2048 ${f}.bam );
        #count the number of reads in BAM files = total number of reads in FR and BR file
        TOTAL=$(samtools view -c -F 0x900 ${f}.bam);
        #host read = total of reads - unmapped reads
        HOST=$(echo $r3 - $r1|bc);
        #print the result out
        echo "Number of total reads in $f: $TOTAL"
        echo "Number of unmapped reads in $f: $MICROBE reads";
        echo "Number of host reads in each file of $f: $HOST reads";
done
#plotting proportion of reads by python
