#!/bin/bash

input_file=$1
stage_path=$2

mkdir -p $stage_path &&
cp $input_file $stage_path &&
pushd $stage_path &&
tar -xzf $(basename $input_file) &&
popd

code=$?
if [ $code -ne 0 ]; then
	echo "Problem staging files!" >&2
	exit $code
fi

exit $code
