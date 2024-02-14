mkdir -p output/lpa
while read i; do 
echo "sample: $i"; 
samtools view -b $i chr6:160530484-160665259 -o output/lpa/$(echo $i | sed 's/.*\/\([A-Z0-9]\+\)\/exome_alignment.*/\1/')".bam";
rm *crai
done < samples/1000G_exome_2504.txt
