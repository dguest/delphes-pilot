#!/bin/bash

# configure the location of the pythia and Delphes executables
MG_DIR=/data7/atlas/cshimmin/zplite/MG5_aMC

PYTHIA_DIR=$MG_DIR/pythia-pgs/src
DELPHES_DIR=/gdata/atlas/cshimmin/zplite/outputs/delphes

LHAPATH=$PYTHIA_DIR/PDFsets

# need to export this magic variable for pythia
export PDG_MASS_TBL=${PYTHIA_DIR}/mass_width_2004.mc

# and make sure pythia can find the LHAPATH
echo "      LHAPATH=$LHAPATH" >> ../Cards/pythia_card.dat

if [ -e "delphes.root" ]; then
	echo "Delphes file already exists! Abort."
	exit 1
fi

# unzip the input events, if necessary
if [ ! -e "unweighted_events.lhe" ]; then
	if [ -e "unweighted_events.lhe.gz" ]; then
		gunzip unweighted_events.lhe.gz
	else
		echo "No events file found!"
		exit 1
	fi
fi

# run pythia
$PYTHIA_DIR/pythia

# run delphes
$DELPHES_DIR/DelphesSTDHEP ../Cards/delphes_card.dat delphes.root pythia_events.hep

# clean the hep file
rm pythia_events.hep
