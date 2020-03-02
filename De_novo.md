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
fastqc T1_R2.fastq.gz
```
## Quality Trimming with Trimmomatic
```{BASH}
trimmomatic-0.39.jar PE input_forward.fq.gz input_reverse.fq.gz output_forward_paired.fq.gz output_forward_unpaired.fq.gz output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:36
```

## Check that quality trimming worked
```BASH
fastqc T1_R2.fastq.gz
```

# Assembly
## Perform SPAdes denovo assembly on Quality trimmed data
```{BASH}
conda activate de_novo
spades.py -k 21,51,71,91,111,127 --careful --pe1-1 T1_R1.cutadapt.fastq --pe1-2 T1_R2.cutadapt.fastq -o T1_spades_output
```

## Check Quality of the Assembly Using QUAST
```{BASH}
cd T1_spades_output
quast contigs.fasta -o Quast_contigs
```
# Annotation

## Copy the T1 SPAdes assembly
```{BASH}
cd /scratch_30_day_tmp/username/in_class_assignments
mkdir prokka_annotation
cp de_novo/T1_spades_output/contigs.fasta prokka_annotation
cd prokka_annotation
```
#### Format the SPAdes assembly to be compatible with prokka
Prokka does not like long names as is the natural output of SPAdes.  To prepare our data for processing with prokka, we must change the names of the contigs.  We will use a unix filter known as `awk` to perform this change.
```{BASH}
awk '/^>/{print ">T1_" ++i; next}{print}' < contigs.fasta > contigs_names.fasta
```
This command is performing the following function.
-  search for lines that start with `>`
-  replace the `>` with `>T1_`
-  after the `T1_` add a number with the first instance being 1 and each instance increasing by 1
-  read in `contigs.fasta`
-  output a new file `contigs_names.fasta

#### Run the prokka pipeline on the `contigs_names.fasta` file.
```{BASH}
prokka --outdir T1 --prefix T1 contigs_names.fasta
```
