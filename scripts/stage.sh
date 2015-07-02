#!/bin/bash

input_file=$1
stage_path=$2

mkdir -p $stage_path/run &&
cp $input_file $stage_path/run/ &&
cp -r Cards/ $stage_path/ &&
cp scripts/process_lhef.sh $stage_path/run/

exit $?
