mkdir -p output/neb output/dmbt1 output/spdye3 output/flg output/ahnak2 output/flg2 output/ubc output/sbsn output/ttn output/muc17 output/muc12 output/lpa
while read i; do 
echo "sample: $i"; 
samtools view -b $i chr6:160530484-160665259 -o output/lpa/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr2:151577914-151609576 -o output/neb/$(echo $i | cut -d'/' -f 8)".bam";  
samtools view -b $i chr10:122599445-122617454 -o output/dmbt1/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr7:100308203-100315286 -o output/spdye3/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr1:152303180-152314028 -o output/flg/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr14:104941568-104953442 -o output/ahnak2/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr1:152354133-152356528 -o output/flg2/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr12:124911751-124913720 -o output/ubc/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr19:35527101-35527847 -o output/sbsn/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr2:178653488-178654118 -o output/ttn/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr7:101031805-101043067 -o output/muc17/$(echo $i | cut -d'/' -f 8)".bam";
samtools view -b $i chr7:100990920-101004942 -o output/muc12/$(echo $i | cut -d'/' -f 8)".bam";
rm *crai
done < samples/1000G_deep_2504.txt
