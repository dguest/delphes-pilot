#!/bin/bash

n_event=1000

show_help() {
	echo "Setup staging area and run madgraph in isolation."
	echo "Usage: $0 [options] gridpack_file"
	echo "  -i OUTPUT_INDEX   The output file index (e.g. unweighted_events_XXX.lhe.gz"
	echo "  -o OUTPUT_PATH    The destination path for output files. (Default: same path as input file)"
	echo "  -n N_EVENT        The number of events per job. (Default: $n_event)"
}

while getopts ":h?i:o:n:" opt; do
    case "$opt" in
    h) show_help
       exit 0
       ;;
    i) output_index=$OPTARG
       ;;
    o) output_path=$OPTARG
       ;;
    n) n_event=$OPTARG
       ;;
   \?) echo "Invalid option: -$OPTARG" >&2
       show_help
       exit 1
       ;;
    :) echo "Option: -$OPTARG requires argument." >&2
       show_help
       exit 1
       ;;
    esac
done

shift $((OPTIND-1))
input_file=$1

if [ -z "$output_index" ]; then
	output_file=unweighted_events.lhe.gz
else
	output_file=unweighted_events._${output_index}.lhe.gz
fi

if [ -z "$output_path" ]; then
	output_path=$(dirname $input_file)
	echo "No output path provided, using $output_path"
fi

if [ ! -d "$output_path" ]; then
	echo "Output path doesn't exist."
	echo "Creating $output_path"
	mkdir -p $output_path
	if [ $? -ne 0 ]; then
		echo "Failed to make output path at $output_path" >&2
		exit 1
	fi
fi

if [ -z "$output_file" ]; then
	echo "No output filename given! Abort." >&2
	exit 1
fi

if [ -e "$output_path/$output_file" ]; then
	echo "Output file already exists! Abort." >&2
	exit 1
fi

if [ ! -z "$SLURM_JOB_ID" ]; then
	echo "Slurm environment detected! Running on $(hostname)."
	echo "Setting random seed from jobid."
	seed=$SLURM_JOB_ID
	echo "Will use local scratch."
	stage_path=/scratch/$(whoami)/mg_${SLURM_JOB_ID}
	mkdir -p $stage_path
else
	echo "Setting random seed from \$RANDOM"
	seed=$RANDOM
	stage_path=$(mktemp -d)
fi

echo "Using random seed=$seed"

clean_stage() {
	echo "Removing staging area at $stage_path"
	rm -rf $stage_path
}

if [ ! -d "$stage_path" ]; then
	echo "Error creating staging path in $stage_path! Abort." >&2
	exit 1
fi

echo "Staging in $stage_path"
echo "./scripts/stage_mg.sh $input_file $stage_path"
./scripts/stage_mg.sh $input_file $stage_path
stage_code=$?
n
if [ $stage_code -ne 0 ]; then
	echo "Staging failed! Code=$stage_code" >&2
	clean_stage
	exit $stage_code
fi

# move into the stage and run the processing scripts
pushd $stage_path
./run.sh $n_event $seed
process_code=$?
popd

if [ $process_code -ne 0 ]; then
	echo "Processing failed! Code=$process_code" >&2
	clean_stage
	exit $process_code
fi

echo "Copying output file..."
cp $stage_path/events.lhe.gz $output_path/$output_file
if [ $? -ne 0 ]; then
	echo "Failed to copy output file!" >&2
	clean_stage
	exit 1
fi

clean_stage
