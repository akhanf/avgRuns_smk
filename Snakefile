configfile: "config.json"

SUBJECTS=["sub-P041"]

#runs beyond the reference run
ref_run="01"
RUNS=["02","03"]


rule all:
    input:
        expand("avg/{subject}_avg.nii.gz",subject=SUBJECTS),
#        expand("plots/{subject}_{run}_reg.svg",subject=SUBJECTS,run=RUNS)


rule grab:
    input:
        os.path.join(config["bids_dir"],"{subject}",config["modality"],"{subject}_acq-"+config["acq"]+"_run-{run}_"+config["suffix"]+".nii.gz")
    output:
        "grab/{subject}_{run}.nii.gz"
    shell:
        "ln -sr {input} {output}"

rule reg:
    input:
        fixed="grab/{subject}_"+ref_run+".nii.gz",
        moving="grab/{subject}_{run}.nii.gz"
    output:
        "reg/{subject}_{run}_reg.nii.gz"
    envmodules:
        "fsl"
    shell:
        "flirt -in {input.moving} -ref {input.fixed} -out {output}"


rule plot_reg:
    input:
        "reg/{subject}_{run}_reg.nii.gz"
    output:
        "plots/{subject}_{run}_reg.svg"
    script:
        "scripts/plot_reg.py"    

rule avg:
    input:
        expand("reg/{{subject}}_{run}_reg.nii.gz",run=RUNS)
    output:
        merged=temp("avg/{subject}_4d.nii.gz"),
        avg="avg/{subject}_avg.nii.gz"
    envmodules:
        "fsl"
    shell:
        "fslmerge -t {output.merged} {input} && "
        "fslmaths {output.merged} -Tmean {output.avg}"


