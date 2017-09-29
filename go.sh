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
NB_BASE_DIR="$PWD"
NB_RUNS_DIR="$NB_BASE_DIR/runs"
NB_JOBS_DIR="$NB_BASE_DIR/jobscripts"
NB_MKNK_DIR="$NB_BASE_DIR/makeneks"
NB_NEK5_DIR="$NB_BASE_DIR/Nek5000"
NB_MCHN_DIR="$NB_BASE_DIR/machines"

NB_THIS_FILE="${BASH_SOURCE[0]}"
if [[ "${#BASH_ARGV[@]}" -ne "$#" ]]; then
   NB_EXIT_CMD=return
else
   NB_EXIT_CMD=exit
fi

NB_HELP_MSG="
$NB_THIS_FILE [options]

options:
   -h|--help                 Print this usage information and exit
   -x|--lx1 \"<list>\"         Specify a list of lx1 values for the run
                                 (Mandatory, e.g., \"3 4 5 6\")
   -y|--ly1 \"<list>\"         Specify a list of ly1 values for the run
                                 (Optional, Default: lx1 list)
   -z|--lz1 \"<list>\"         Specify a list of lz1 values for the run
                                 (Optional, Default: lx1 list)
   -e|--lelt \"<list>\"        Specify a list of lelt values for the run
                                 (Mandatory, e.g., \"128 256\")
   -n|--np \"<list>\"          Specify a list of MPI ranks for the run
                                 (e.g., \"2 4 8\"; Default: 1)
   -m|--machine machine_name Specify a machine for the run
                                 (Mandatory, e.g., theta, cetus, ..)
   -t|--test \"<list>\"        Specify a list of tests to be run
                                 (e.g., scaling, pingpong,...; Default: scaling)
   -c|--case case_name       Specify the path of the case to be used
                                 in benchmarking (e.g.,/home/nek_user/cases/box)
   --even-lxd                Round down lxd to an even value
"

#-----------------------------------------------------------------------
# Variables
#-----------------------------------------------------------------------
nb_debug_scripts=false
nb_test_functions=false

nb_lx1_list=
nb_lx1_set=false
nb_ly1_list=
nb_lz1_list=

nb_lelt_list=
nb_lelt_set=false

nb_np_list="4" # <- default value
nb_np_set=true
nb_lp_min="4"  # <- default value
nb_lp_max="4"  # <- default value

nb_machine="linux"
nb_machine_set=true

nb_test_list="scaling" # <- default value
nb_test_set=true

nb_case=
nb_case_set=false

nb_even_lxd=false

#-----------------------------------------------------------------------
# Include helper functions
#-----------------------------------------------------------------------
source ./functions.sh

#-----------------------------------------------------------------------
# Read input arguments
#-----------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
         -h|--help)
           echo "$NB_HELP_MSG"
           $NB_EXIT_CMD
           ;;
         -x|--lx1)
           shift
           nb_lx1_list="$1"
           nb_lx1_set=true
           ;;
         -y|--ly1)
           shift
           nb_ly1_list="$1"
           ;;
         -z|--lz1)
           shift
           nb_lz1_list="$1"
           ;;
         -e|--lelt)
           shift
           nb_lelt_list="$1"
           nb_lelt_set=true
           ;;
         -n|--np)
           shift
           nb_np_list="$1"
           nb_np_set=true
           nb_lp_min=$(min ${nb_np_list[@]})
           nb_lp_max=$(max ${nb_np_list[@]})
           ;;
         -m|--machine)
           shift
           nb_machine=$1
           nb_machine_set=true
           ;;
         -t|--test)
           shift
           nb_test_list="$1"
           ;;
         -c|--case)
           shift
           nb_case=$1
           nb_case_set=true
           ;;
         --even-lxd)
           nb_even_lxd=true
           ;;
         clean)
           rm -rf $NB_RUNS_DIR/*
           echo "rm -rf $NB_RUNS_DIR/*"
           exit
           ;;
  esac
  shift
done # end reading arguments

#-----------------------------------------------------------------------
# Print debug information
#-----------------------------------------------------------------------
if [ ${nb_debug_scripts} = true ]; then
  echo "$nb_lx1_set"
  echo "$nb_lelt_set"
  echo "$nb_np_set"
  echo "$nb_machine_set"
  echo "$nb_test_set"
  echo "$nb_case_set"
  echo "lx1 = $nb_lx1_list"
  echo "ly1 = $nb_ly1_list"
  echo "lz1 = $nb_lz1_list"
  echo "lelt = $nb_lelt_list"
  echo "np = $nb_np_list"
  echo "lp_min = $nb_lp_min"
  echo "lp_max = $nb_lp_max"
  echo "machine = $nb_machine"
  echo "test = $nb_test_list"
  $NB_EXIT_CMD
fi

#-----------------------------------------------------------------------
# Check if the requited variables are set
#-----------------------------------------------------------------------
if [ ${nb_lx1_set} = false ] || [ ${nb_lelt_set} = false ] \
      || [ ${nb_np_set} = false ]; then
  echo "All lx1, lelt, and np parameters must be provided."
  $NB_EXIT_CMD
fi

if [ ${nb_case_set} = false ] || ! [ -d "${nb_case}" ]; then
  echo "Case name missing or case does not exist."
  $NB_EXIT_CMD
fi
nb_case=$(cd $nb_case ; pwd)
nb_case_basename=$(basename $nb_case)

if [ ${nb_test_list} = "pingpong" ] && [ ${nb_case_set} = false ]; then
  nb_case_set=true
  nb_case="./built-in/pngpng"
fi

#-----------------------------------------------------------------------
# Set ly1 and lz1 to lx1 by default if not specified
#-----------------------------------------------------------------------
if [ ${#nb_ly1_list} -eq 0 ]; then
  nb_ly1_list=$nb_lx1_list
fi
if [ ${#nb_lz1_list} -eq 0 ]; then
  nb_lz1_list=$nb_lx1_list
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
mkdir -p $NB_RUNS_DIR/$nb_machine 2> /dev/null
. ./build.sh

#-----------------------------------------------------------------------
# Go through the test list and perform them
#-----------------------------------------------------------------------
for tst in $nb_test_list; do
   if [ $tst = "scaling" ]; then
     . ./scaling.sh
   elif [ $tst = "pingpong" ]; then
     . ./pingpong.sh
   fi
done
