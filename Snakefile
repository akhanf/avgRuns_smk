from os.path import join
from bids import BIDSLayout


configfile: "config.yaml"


# bids_dir and out_dir set in json file.
# can also override at command-line with e.g.:  --config bids_dir='path/to/dir'  or --configfile ...
bids_dir = config['bids_dir']
out_dir = config['out_dir']

# this uses pybids to get info about the bids dataset (validate=False allows for non-validated tags)
layout = BIDSLayout(bids_dir, validate=False)

#get entities from cfg file to select input files
entities = config['entities']
print(entities)

# get subjects, sessions, runs etc from pybids
subjects = layout.get_subjects(**entities)
sessions = layout.get_sessions(**entities)
runs = layout.get_runs(**entities)

print(subjects)
print(sessions)
print(runs)



#create strings including wildcards for subj_sess_dir and subj_sess_prefix
if len(sessions) > 0:
    subj_sess_dir = join('sub-{subject}','ses-{session}')
    subj_sess_prefix = 'sub-{subject}_ses-{session}'
else:
    subj_sess_dir = 'sub-{subject}'
    subj_sess_prefix = 'sub-{subject}'

datatype = config['entities']['datatype']
acq = config['entities']['acq']
suffix = config['entities']['suffix']



rule all:
    input:
        expand( join(out_dir,subj_sess_dir,datatype,subj_sess_prefix + '_proc-avg_' + suffix + '.nii.gz' ), subject=subjects,session=sessions)
    shell:
        "echo {input}"
   
rule avg:
    input:
        reg = expand(join(out_dir,subj_sess_dir,datatype,subj_sess_prefix + '_run-0{run}_proc-reg_' + suffix + '.nii.gz' ), run=runs, allow_missing=True)
    output:
        merged = join(out_dir,subj_sess_dir,datatype,subj_sess_prefix + '_proc-merged_' + suffix + '.nii.gz' ),
        avg = join(out_dir,subj_sess_dir,datatype,subj_sess_prefix + '_proc-avg_' + suffix + '.nii.gz' )
    envmodules:
        "fsl"
    shell:
        "fslmerge -t {output.merged} {input} && "
        "fslmaths {output.merged} -Tmean {output.avg}"


rule reg:
    input:
        fixed = join(bids_dir,subj_sess_dir,datatype,subj_sess_prefix + '_acq-' + acq + '_run-01_' + suffix + '.nii.gz' ),
        moving = join(bids_dir,subj_sess_dir,datatype,subj_sess_prefix + '_acq-' + acq + '_run-0{run}_' + suffix + '.nii.gz' ),
    output:
        reg = join(out_dir,subj_sess_dir,datatype,subj_sess_prefix + '_run-0{run}_proc-reg_' + suffix + '.nii.gz' ),
    envmodules:
        "fsl"
    shell:
        "flirt -in {input.moving} -ref {input.fixed} -out {output}"

#rule plot_reg:
#    input:
#        "reg/{subject}_{run}_reg.nii.gz"
#    output:
#        "plots/{subject}_{run}_reg.svg"
#    script:
#        "scripts/plot_reg.py"    


