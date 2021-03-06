# Install minconda to easily install packages and dependencies
## Obtain and install Miniconda
```{BASH}
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```
- During the install, you will be asked to read the End User Agreement and accept the license
- You will also be asked if you want to initialize miniconda - say yes

- After installation is successful run the following command
```{BASH}
source ~/.bashrc
```
# Install programs needed for **de novo** assembly and annotation
```{BASH}
conda create -n de_novo -c bioconda -c conda-forge fastqc=0.11.5 \
             trimmomatic=0.36 spades=3.11.1 quast=5.0.2 \
             bowtie2=2.2.5 prokka java-jdk=8.0.112 --yes
```
## Activate the environment
```{BASH}
conda activate de_novo
```

# Download Data
Your data is in a folder on the server called genomics

# Perform Quality Assessment and Quality Control

## Use fastqc to assess the quality of these reads  
```BASH
fastqc G15_S3_L001_R1_001.fastq.gz
```
## Quality Trimming with Trimmomatic
```{BASH}
trimmomatic PE G15_S3_L001_R1_001.fastq.gz G15_S3_L001_R2_001.fastq.gz G15_pair_R1.fastq.gz G15_unpair_R1.fastq.gz G15_pair_R2.fastq.gz G15_unpair_R2.fastq.gz ILLUMINACLIP:~/miniconda3/pkgs/trimmomatic-0.36-6/share/trimmomatic-0.36-6/adapters/NexteraPE-PE.fa:2:30:10:2 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```

## Check that quality trimming worked
```BASH
fastqc G15_pair_R1.fastq.gz
```

# Assembly
## Perform SPAdes denovo assembly on Quality trimmed data
```{BASH}
spades.py -k 21,51,71,91,111,127 --careful --pe1-1 G15_pair_R1.fastq.gz --pe1-2 G15_pair_R2.fastq.gz --pe1-s G15_unpair_R1.fastq.gz -o G15_spades_output
```

## Check Quality of the Assembly Using QUAST
```{BASH}
cd G15_spades_output
quast contigs.fasta -o G15_Quast_contigs
```
# Annotation

## Copy the SPAdes assembly
```{BASH}
cd ~/data/genomics/
mkdir prokka_annotation
cp G15_spades_output/contigs.fasta prokka_annotation/
cd prokka_annotation
```
#### Format the SPAdes assembly to be compatible with prokka
Prokka does not like long names as is the natural output of SPAdes.  To prepare our data for processing with prokka, we must change the names of the contigs.  We will use a unix filter known as `awk` to perform this change.
```{BASH}
awk '/^>/{print ">G15_" ++i; next}{print}' < contigs.fasta > contigs_names.fasta
```
This command is performing the following function.
-  search for lines that start with `>`
-  replace the `>` with `>T1_`
-  after the `G15_` add a number with the first instance being 1 and each instance increasing by 1
-  read in `contigs.fasta`
-  output a new file `contigs_names.fasta

#### Run the prokka pipeline on the `contigs_names.fasta` file.
```{BASH}
prokka --outdir G15 --prefix G15 --locustag G15 contigs_names.fasta
```
