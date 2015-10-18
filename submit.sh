#!/bin/bash

# defaults
ncores=2
quiet=1
recurse=0
partition=atlas_all
tlimit=30

show_help() {
	echo "Submit pythia/delphes jobs to the slurm cluster."
	echo "Usage: $0 [options] input_file [input_file ...]"
	echo "Options:"
	echo "  -r              Recursively find unweighted_events.lhe(.gz) files in the given directory."
	echo "  -m MAX_JOB      Maximum number of files to process. (For use with -r only)"
	echo "  -d DELPHES_CARD Path to the desired delphes card to run."
	echo "  -t TAG_NAME     A prefix tag for output files (e.g. <TAG_NAME>_delphes.root)."
	echo "  -c N_CORES      Number of cores to request per job. (Default: $ncores)"
	echo "  -p PARTITION    The slurm partition to submit to. (Default: $partition)"
	echo "  -l TLIMIT       The time limit (in minutes). (Default: $tlimit)"
	echo "  -v              Don't squelch slurm logs."
}

# parse CLI
while getopts ":h?rm:d:t:c:p:l:v" opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    r)  recurse=1
        ;;
    m)  max_job=$OPTARG
        ;;
    d)  delphes_card=$OPTARG
        ;;
    t)  tag=$OPTARG
        ;;
    c)  ncores=$OPTARG
        ;;
    p)  partition=$OPTARG
        ;;
    l)  tlimit=$OPTARG
        ;;
    v)  quiet=0
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

if [ "$recurse" == "0" ]; then
	input_files=$@
else
	search_str=".*\(unweighted_events\|sherpa_events\)\(\._.*\)?\.\(lhe\|hepmc2g\)\(\.gz\)?"
	if [ -z "$max_job" ]; then
		input_files=$(find -L $1 -regex $search_str)
	else
		input_files=$(find -L $1 -regex $search_str | sort | head -n $max_job)
	fi
fi

# setup options to sbatch command
SLURM_OPTS="-c $ncores -p $partition -t $tlimit"

if [ "$quiet" == "1" ]; then
	SLURM_OPTS+=" -o /dev/null"
fi

if [ "$recurse" == "1" ]; then
	SLURM_OPTS+=" -J $(basename $1)"
fi

RUN_OPTS=""
if [ ! -z "$delphes_card" ]; then
	RUN_OPTS+=" -d $delphes_card"
fi
if [ ! -z "$tag" ]; then
	RUN_OPTS+=" -t $tag"
fi

# schedule a job for each input file
for input_file in $input_files; do
	echo "Submitting job for $input_file"
	sbatch $SLURM_OPTS ./run.sh $RUN_OPTS $input_file
done
