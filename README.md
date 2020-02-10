# avgRuns_smk
Snakemake workflow for register and avg runs from a bids dataset

TO DO: 
 * try using profiles instead of clunky definition of --cluster option
 * think about best practices for using snakemake with BIDS
 * also a potential replacement for bidsBatch??


# Initial setup on graham:

```
#install miniconda3 in home dir using easybuild
eb miniconda3 

#note: if not on graham, can install miniconda3 by running official install script
conda init
source ~/.bashrc
pip install snakemake==5.10.0

#you will need these for --report
conda install jinja2 networkx pygraphvis pygraphviz pygments
```

# Running with sbatch:

Note: envmodules didn't seem to be working when the --cluster command was used.. will need to confirm..
```
snakemake  --cluster "sbatch --account=rrg-akhanf --time=3:00:00 --mem=4000"  -j 4 --use-envmodules
```

