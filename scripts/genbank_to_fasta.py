#/usr/bin/env python

from Bio import SeqIO
import sys

gbk_filename = sys.argv[1]
fasta_filename = sys.argv[2]

input_handle  = open(gbk_filename, "r")
output_handle = open(fasta_filename, "w")

for seq_record in SeqIO.parse(input_handle, "genbank") :
    for seq_feature in seq_record.features :
        if seq_feature.type=="CDS" :
            assert len(seq_feature.qualifiers['translation'])==1
            output_handle.write(">%s [%s] from %s\n%s\n" % (
                   seq_feature.qualifiers['locus_tag'][0],
                   seq_feature.qualifiers['product'][0],
                   seq_record.name,
                   seq_feature.qualifiers['translation'][0]))

output_handle.close()
input_handle.close()
