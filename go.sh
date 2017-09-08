#!/bin/bash

#-----------------------------------------------------------------------
# lx1 range
# lelt range
# np range
# machine -- cetus, theta, ??
# Test type
#       nodewise performance?
#       internode communication?
#       intranode-communication?
#       platform timer? mxm_tests? comm_tests?
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Constants
#-----------------------------------------------------------------------
BASE_DIR="$PWD"
RUNS_DIR="$BASE_DIR/runs"
NEK5_DIR=""
JOBS_DIR="$BASE_DIR/jobscripts"

THIS_FILE="${BASH_SOURCE[0]}"
if [[ "${#BASH_ARGV[@]}" -ne "$#" ]]; then
   EXIT_CMD=return
else
   EXIT_CMD=exit
fi

HELP_MSG="
$THIS_FILE [options]

options:
   -h|--help                   Print this usage information and exit
   -x|--lx1 \"<list>\"         Specify a list of lx1 values for the run
                                 (Mandatory, e.g., \"3 4 5 6\")
   -y|--ly1 \"<list>\"         Specify a list of ly1 values for the run
                                 (Optional, Default: lx1 list)
   -z|--lz1 \"<list>\"         Specify a list of lz1 values for the run
                                 (Optional, Default: lx1 list)
   -e|--lelt \"<list>\"        Specify a list of lelt values for the run
                                 (Mandatory, e.g., \"128 256\")
   -n|--np \"<list>\"          Specify a list of MPI rank for the run
                                 (Mandatory, e.g., \"2 4 8\")
   -m|--machine \"machine\"    Specify a machine for the run
                                 (Mandatory, e.g., theta, cetus, ..)
   -t|--test \"<list>\"        Specify a list of tests to be run
                                 (Mandatory, e.g., scaling, pingpong,..)
   -c|--case \"case_name\"     Specify a case to be used in benchmarking
                                 (Use the full path of the case, e.g.,
                                   /home/nek_user/cases/box)
"

#-----------------------------------------------------------------------
# Include helper functions
#-----------------------------------------------------------------------
source ./functions.sh

#-----------------------------------------------------------------------
# Variables
#-----------------------------------------------------------------------
debug=false

lx1_list=
lx1_set=false
ly1_list=
lz1_list=

lelt_list=
lelt_set=false

np_list=
np_set=false
lp_min=
lp_max=

machine=
machine_set=false

test_list=
test_set=false

case=
case_set=false

#-----------------------------------------------------------------------
# Read input arguments
#-----------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
         -h|--help)
           echo "$HELP_MSG"
           $EXIT_CMD
           ;;
         -x|--lx1)
           shift
           lx1_list="$1"
           lx1_set=true
           ;;
         -y|--ly1)
           shift
           ly1_list="$1"
           ;;
         -z|--lz1)
           shift
           lz1_list="$1"
           ;;
         -e|--lelt)
           shift
           lelt_list="$1"
           lelt_set=true
           ;;
         -n|--np)
           shift
           np_list="$1"
           np_set=true
           lp_min=$(min "${np_list[@]}")
           lp_max=$(max "${np_list[@]}")
           ;;
         -m|--machine)
           shift
           machine=$1
           machine_set=true
           ;;
         -t|--test)
           shift
           test_list="$1"
           test_set=true
           ;;
         -c|--case)
           shift
           case=$1
           case_set=true
           ;;
  esac
  shift
done # end reading arguments

#-----------------------------------------------------------------------
# Check if the requited variables are set
#-----------------------------------------------------------------------
if [ ${debug} = true ]; then
  echo "$lx1_set"
  echo "$lelt_set"
  echo "$np_set"
  echo "$machine_set"
  echo "$test_set"
  echo "$case_set"
  echo "lx1 = $lx1_list"
  echo "ly1 = $ly1_list"
  echo "lz1 = $lz1_list"
  echo "lelt = $lelt_list"
  echo "np = $np_list"
  echo "machine = $machine"
  echo "test = $test_list"
  $EXIT_CMD
fi

if [ ${lx1_set} = false ] || [ ${lelt_set} = false ] \
      || [ ${np_set} = false ] || [ ${machine_set} = false ] \
      || [ ${test_set} = false ] ; then
  echo "You need to specify all lx1, lelt, np, machine and test parameters."
  $EXIT_CMD
fi

if [ ${test_list} != "pingpong" ] && [ ${case_set} = false ]; then
  echo "If the test is not equal to pingpong, need to specify a case name."
  $EXIT_CMD
elif [ ${test_list} = "pingpong" ]; then
  case_set=true
  case="./built-in/pngpng"
fi

#-----------------------------------------------------------------------
# Set ly1 and lz1 to lx1 by default if not specified
#-----------------------------------------------------------------------
if [ ${#ly1_list} -eq 0 ]; then
  ly1_list=$lx1_list
fi
if [ ${#lz1_list} -eq 0 ]; then
  lz1_list=$lx1_list
fi

#-----------------------------------------------------------------------
# See if Nek5000 exist in the current directory
#-----------------------------------------------------------------------
if [ -d "Nek5000" ]; then
  echo "Using existing Nek5000 directory ..."
else
  echo "Cloning the latest version from github ..."
  git clone https://github.com/Nek5000/Nek5000.git
fi

#-----------------------------------------------------------------------
# Create the benchmark directories
#-----------------------------------------------------------------------
case=$(readlink -f $case)
case_basename=$(basename $case)
mkdir -p $RUNS_DIR/$case_basename
. ./build.sh

#-----------------------------------------------------------------------
# Go through the test list and perform them
#-----------------------------------------------------------------------
for tst in $test_list; do
   if [ $tst = "scaling" ]; then
     . ./scaling.sh
   elif [ $tst = "pingpong" ]; then
     . ./pingpong.sh
   fi
done

if [ ${debug} = true ]; then
  echo "lx1 = $lx1_list"
  echo "ly1 = $ly1_list"
  echo "lz1 = $lz1_list"
  echo "lelt = $lelt_list"
  echo "np = $np_list"
  echo "machine = $machine"
fi
