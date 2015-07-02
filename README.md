# delphes-pilot

Simple driver scripts to run pythia/delphes quickly in an isolated staging environment.
Especially useful for iterative testing or to parallelize processing of .lhe files outside of madevent.

Running in local mode, the script will setup a directory in `/tmp` to process the file.
When running on the cluster, the `.lhe` input is copied to a directory in `/scratch/<username>/` and processed from there.

## Setup
Edit `config.sh` to point at your installation of pythia and Delphes.
If you're using the madgraph-provided versions, you can just set `MG_DIR` in the example config provided.

If you want to modify the pythia/Delphes cards used during the processing, either edit the default ones in `Cards/`, or symlink them to your own.

## Use
To run locally, simply do:
```
./run.sh /path/to/some/file.lhe(.gz)
```

Unless otherwise specified, the processed delphes output will be saved to the same directory as the input file, under the name `delphes.root`.
Have a look at `./run.sh -h` for more options.

If you want to process multiple files on the slurm cluster, use the submit script provided:
```
./submit.sh some_lhe_file [some_lhe_file ...]
```
Have a look at `./submit.sh -h` for more options.
