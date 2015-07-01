#!/bin/bash

for input_file in $@; do
	sbatch -c 2 -p atlas_all -t 120 ./run.sh $input_file
done
