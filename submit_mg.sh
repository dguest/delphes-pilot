#!/bin/bash

# default
n_job=100
n_event=1000
ncores=2
quiet=1
partition=atlas_all
tlimit=30

show_help() {
	echo "Submit madgraph jobs to the slurm cluster."
	echo "Usage: $0 [options] gridpack_file"
	echo "Options:"
	echo "  -j N_JOB        The number of jobs to submit. (Default: $n_job)"
	echo "  -n N_EVENT      The number of events per job. (Default: $n_event)"
	echo "  -o OUTPUT_DIR   The output directory for generated events. (Default: same as input file)"
	echo "  -s OFFSET       The offset number for output file sequence."
	echo "  -c N_CORES      Number of cores to request per job. (Default: $ncores)"
	echo "  -p PARTITION    The slurm partition to submit to. (Default: $partition)"
	echo "  -l TLIMIT       The time limit (in minutes). (Default: $tlimit)"
	echo "  -v              Don't squelch slurm logs."
}

# parse CLI
while getopts ":h?j:n:o:s:c:p:v" opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    j)  n_job=$OPTARG
        ;;
    n)  n_event=$OPTARG
        ;;
    o)  output_dir=$OPTARG
        ;;
    s)  n_offset=$OPTARG
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

input_file=$1

if [ ! -e "$input_file" ]; then
	echo "Cannot find input file: $input_file" >&2
	exit 1
fi

# setup options to sbatch command
SLURM_OPTS="-c $ncores -p $partition -t $tlimit"

if [ "$quiet" == "1" ]; then
	SLURM_OPTS+=" -o /dev/null"
fi

RUN_OPTS="-n $n_event"
if [ ! -z "$output_dir" ]; then
	RUN_OPTS+=" -o $output_dir"
fi

# schedule the requested number of jobs
if [ -z "$n_offset" ]; then
	nums=$(seq -f "%04g" $n_job)
else
	nums=$(seq -f "%04g" $((n_offset+1)) $((n_offset+n_job)))
fi
for idx in $nums; do
	echo "Submitting job $idx"
	sbatch $SLURM_OPTS ./run_mg.sh $RUN_OPTS -i $idx $input_file
done
