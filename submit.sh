#!/bin/bash

show_help() {
	echo "Submit pythia/delphes jobs to the slurm cluster."
	echo "Usage: $0 [options] input_file [input_file ...]"
	echo "Options:"
	echo "  -t TAG_NAME     A prefix tag for output files."
	echo "  -c N_CORES      Number of cores to request per job."
	echo "  -p PARTITION    The slurm partition to submit to."
	echo "  -q              Squelch slurm logs."
}

# defaults
ncores=2
quiet=0
partition=atlas_all

# parse CLI
while getopts ":h?t:c:p:q" opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    t)  tag=$OPTARG
        ;;
    c)  ncores=$OPTARG
        ;;
    p)  partition=$OPTARG
        ;;
    q)  quiet=1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
	show_help
	exit 1
	;;
    :)
        echo "Option: -$OPTARG requires argument." >&2
	show_help
	exit 1
	;;
    esac
done

# shift to arguments to list of input files
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
	echo "No input files provided! Abort." >&2
	show_help
	exit 1
fi

# add a tag to the input filename, if requested.
output_name=delphes.root
if [ ! -z "$tag" ]; then
	output_name=${tag}_${output_name}
fi

# setup options to sbatch command
SLURM_OPTS="-c $ncores -p $partition -t 120"

if [ "$quiet" == "1" ]; then
	SLURM_OPTS+=" -o /dev/null"
fi

# schedule a job for each input file
for input_file in $@; do
	echo "Submitting job for $input_file"
	sbatch $SLURM_OPTS ./run.sh -n $output_name $input_file
done
