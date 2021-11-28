# Make a BLASTable database
Using the the `.faa` file from one of your genomes make a blastable database.
```{BASH}
makeblastdb -in genome1.faa -dbtype prot -out Genome1_db
```

# BLAST one genome against the other
```{BASH}
blastp -db Genome1_db -query Genome2.faa -out Genome2_BLAST.txt -evalue 1e-30 -qcov_hsp_perc 90 -num_alignments 1 -outfmt 6 
```
- Each line will be a gene with a homolog in the other genome.
- This approach will allow you to identify homologs in the two genomes.
