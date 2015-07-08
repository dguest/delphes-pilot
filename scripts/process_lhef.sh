#!/bin/bash

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
		if [ $? -ne 0 ]; then
			echo "Failed to unzip LHE!" >&2
			exit 1
		fi
	else
		echo "No events file found!" >&2
		exit 1
	fi
fi

# run pythia
#$PYTHIA_DIR/pythia

#pythia_code=$?
#if [ $pythia_code -ne 0 ]; then
#	echo "Pythia returned error! Code=$pythia_code" >&2
#	exit $pythia_code
#fi

# run delphes
#$DELPHES_DIR/DelphesSTDHEP ../Cards/delphes_card.dat delphes.root pythia_events.hep

$DELPHES_DIR/DelphesPythia8 ../Cards/delphes_card.dat ../Cards/configLHE.cmnd delphes.root

delphes_code=$?
if [ $delphes_code -ne 0 ]; then
	echo "Delphes returned error! Code=$delphes_code" >&2
	exit $delphes_code
fi

# clean the hep file
#rm pythia_events.hep
