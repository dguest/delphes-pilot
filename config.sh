#sourceme

# point to MG dir, which is usually where Pythia and Delphes live.
MG_DIR=/home/dguest/substructure/MG5_aMC_v2_2_3

### The following variables must be exported.
### Configure them to match your system.

# Point to the /src directory of the pythia distribution (should
# be compatible with the version distributed by MG).
export PYTHIA_DIR=${MG_DIR}/pythia-pgs/src

# Point to the root Delphes directory (should be compatible with the
# version distributed by MG).
export DELPHES_DIR=/home/dguest/substructure/delphes

# Set to 1 if you want to use Delphes internal pythia8 showering.
# Note that this requires that you built the DelphesPythia8 binary.
export USE_PYTHIA8=0
