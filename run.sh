#!/bin/bash

show_help() {
	echo "Setup staging area and run pythia/delphes in isolation."
	echo "Usage: $0 [options] input_file"
	echo "  -o OUTPUT_PATH    The destination path for output file."
	echo "  -n OUTPUT_NAME    The output filename."
}

output_name=delphes.root

while getopts ":h?o:n:" opt; do
    case "$opt" in
    h) show_help
       exit 0
       ;;
    o) output_path=$OPTARG
       ;;
    n) output_name=$OPTARG
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

if [ $# -lt 1 ]; then
	echo "No input file provided! Abort." >&2
	show_help
	exit 1
fi

if [ ! -e "$input_file" ]; then
	echo "Cannot find input file. Abort." >&2
	exit 1
fi

if [ -z "$output_path" ]; then
	output_path=$(dirname $input_file)
	echo "No output path provided, using $output_path"
fi

if [ ! -z "$SLURM_JOB_ID" ]; then
	echo "Slurm environment detected! Running on $(hostname)."
	echo "Will use local scratch."
	stage_path=/scratch/$(whoami)/delphes_${SLURM_JOB_ID}
	mkdir -p $stage_path
else
	stage_path=$(mktemp -d)
fi

if [ ! -d "$stage_path" ]; then
	echo "Error creating staging path in $stage_path! Abort." >&2
	exit 1
fi

output_file=$output_path/$output_name

# setup the working directory for pythia and delphes to run in
echo "Staging in $stage_path"
./scripts/stage.sh $input_file $stage_path

# move to the stage and run the processing scripts
echo "Running scripts..."
pushd $stage_path/run
./process_lhef.sh
popd

echo "Copying output file..."
cp $stage_path/run/delphes.root $output_file

echo "Removing staging area..."
rm -rf $stage_path
