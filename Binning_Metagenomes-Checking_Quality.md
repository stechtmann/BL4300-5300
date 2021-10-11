##

## Download database

Install checkm
```{BASH}
conda install -c bioconda -n Applied_Genomics checkm-genome
```

Set the database directory
```{BASH}
checkm data setRoot /home/campus14/smtechtm/miniconda3/envs/Applied_Genomics/checkm_data
```
## Changes names of metabat2 output bins

```{BASH}
for file in *.fa 
do 
mv $file "${file%.fa}.fna" 
done
```

## Assign taxonomy to bins

```{BASH}
checkm lineage_wf bin/ checkm_out/ --reduced_tree
```
