#!/bin/bash

input_file=$1
stage_path=$2

delphes_card=$3

mkdir -p $stage_path/run &&
cp $input_file $stage_path/run/unweighted_events.lhe.gz &&
cp -r Cards/ $stage_path/ &&
cp scripts/process_lhef.sh $stage_path/run/

code=$?
if [ $code -ne 0 ]; then
	echo "Problem staging files!" >&2
	exit $code
fi

if [ ! -z "$delphes_card" ]; then
	echo "Copying custom delphes_card.dat from $delphes_card"
	cp $delphes_card $stage_path/Cards/delphes_card.dat
fi

exit $?
