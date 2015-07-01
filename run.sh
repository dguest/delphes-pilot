#!/bin/bash

input_file=$1
output_file=$2

if [ -z "$input_file" ]; then
	echo "No input file provided! Abort."
	exit 1
fi

if [ ! -e "$input_file" ]; then
	echo "Cannot find input file. Abort."
	exit 1
fi

if [ -z "$output_file" ]; then
	output_file=$(dirname $input_file)/delphes.root
	echo "No output file provided, using $output_file"
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
	echo "Error creating staging path in $stage_path! Abort."
	exit 1
fi

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
