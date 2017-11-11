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
NB_BENCH_DIR="$NB_BASE_DIR/benchmarks"
NB_JOBS_DIR="$NB_BASE_DIR/jobscripts"
NB_MKNK_DIR="$NB_BASE_DIR/makeneks"
NB_MCHN_DIR="$NB_BASE_DIR/machines"
NB_TIME_DATA="time.nbdata"
NB_README_FILE="README"
NB_RUN_DIR_PREFIX="run"
NB_RUN_DIR_NUM_LEN=3

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
   -p|--ppn \"<list>\"         Specify a list of MPI ranks per node for the run
                                 (e.g., \"2 4 8\"; Default: 1)
   -m|--machine machine_name Specify a machine for the run
                                 (Mandatory, e.g., theta, cetus, ..)
   -t|--tag name             Specify a name for the run
                                 (e.g., scaling, pingpong,...; Default: scaling)
   -c|--case case_name       Specify the path of the case to be used
                                 in benchmarking (e.g.,/home/nek_user/cases/box)
   --plot options            Plot the benchmark data
   --even-lxd                Round down lxd to an even value
   clean                     Clean the runs directory
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

nb_ppn_list=
nb_ppn_set=false

nb_machine="linux"
nb_machine_set=true

nb_tag=
nb_tag_set=false

nb_case=
nb_case_set=false

nb_even_lxd=false

np_plot_type=
nb_plot_set=false

#-----------------------------------------------------------------------
# Include helper functions
#-----------------------------------------------------------------------
source ./functions.sh

#-----------------------------------------------------------------------
# Print welcome message
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Read input arguments
#-----------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
         -h|--help)
           iprint "$NB_HELP_MSG"
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
         -p|--ppn)
           shift
           nb_ppn_list="$1"
           nb_ppn_set=true
           ;;
         -m|--machine)
           shift
           nb_machine=$1
           nb_machine_set=true
           ;;
         -t|--tag)
           shift
           nb_tag=$1
           nb_tag_set=true
           ;;
         -c|--case)
           shift
           nb_case=$1
           nb_case_set=true
           ;;
         --plot)
           shift
           nb_plot_type=$1
           nb_plot_set=true
           ;;
         --even-lxd)
           nb_even_lxd=true
           ;;
         clean)
           rm -rf $NB_RUNS_DIR/*
           echo "rm -rf $NB_RUNS_DIR/*"
           $NB_EXIT_CMD
           ;;
  esac
  shift
done # end reading arguments

#-----------------------------------------------------------------------
# Convert input lists to bash arrays
#-----------------------------------------------------------------------
nb_lx1_list=(${nb_lx1_list})
nb_ly1_list=(${nb_ly1_list})
nb_lz1_list=(${nb_lz1_list})
nb_lelt_list=(${nb_lelt_list})
nb_np_list=(${nb_np_list})
nb_ppn_list=(${nb_ppn_list})
nb_machine_list=(${nb_machine}) # For plotting, nb_machine can be a list
nb_tag_list=(${nb_tag}) # For plotting, nb_tag can be a list

#-----------------------------------------------------------------------
# Check if user wants to plot. If so, plot and exit
#-----------------------------------------------------------------------
if [ $nb_plot_set = true ] && [ $nb_tag_set = true ]; then
  . ./plot.sh $nb_plot_type

  $NB_EXIT_CMD
fi

#-----------------------------------------------------------------------
# Set ly1 and lz1 to lx1 by default if not specified
#-----------------------------------------------------------------------
if [ ${#nb_ly1_list[@]} -eq 0 ]; then
  nb_ly1_list=(${nb_lx1_list[@]})
fi
if [ ${#nb_lz1_list[@]} -eq 0 ]; then
  nb_lz1_list=(${nb_lx1_list[@]})
fi

#-----------------------------------------------------------------------
# Check if the requited variables are set
#-----------------------------------------------------------------------
if [ ${nb_lx1_set} = false ] || [ ${nb_lelt_set} = false ] \
      || [ ${nb_np_set} = false ] || [ $nb_tag_set = false ] ; then
  iprint "lx1, lelt, tag and np parameters must be provided. Exitting ..."
  $NB_EXIT_CMD
fi

if [ ${nb_case_set} = false ] || ! [ -d "${nb_case}" ]; then
  iprint "Case name missing or case does not exist."
  $NB_EXIT_CMD
fi
nb_case=$(cd $nb_case ; pwd)
nb_case_basename=$(basename $nb_case)

if [ ${nb_ppn_set} = true ]; then
  if [ ${#nb_np_list[@]} -ne ${#nb_ppn_list[@]} ]; then
    iprint "len(ppn list) != len(np list). Ignoring ppn list ..."
    nb_ppn_set=false
  fi
fi

#-----------------------------------------------------------------------
# Print debug information
#-----------------------------------------------------------------------
if [ ${nb_debug_scripts} = true ]; then
  echo "lx1_set = $nb_lx1_set"
  echo "lelt_set = $nb_lelt_set"
  echo "np_set = $nb_np_set"
  echo "ppn_set = $nb_ppn_set"
  echo "machine_set = $nb_machine_set"
  echo "tag_set = $nb_tag_set"
  echo "case_set = $nb_case_set"
  echo "lx1 = ${nb_lx1_list[@]}; ${#nb_lx1_list[@]}"
  echo "ly1 = ${nb_ly1_list[@]}; ${#nb_ly1_list[@]}"
  echo "lz1 = ${nb_lz1_list[@]}; ${#nb_lz1_list[@]}"
  echo "lelt = ${nb_lelt_list[@]}; ${#nb_lelt_list[@]}"
  echo "np = ${nb_np_list[@]}; ${#nb_np_list[@]}"
  echo "lp_min = $nb_lp_min"
  echo "lp_max = $nb_lp_max"
  echo "machine = $nb_machine"
  echo "ppn = ${nb_ppn_list[@]}; ${#nb_ppn_list[@]}"
  echo "tag = $nb_tag"
  $NB_EXIT_CMD
fi

#-----------------------------------------------------------------------
# Create the benchmark directories
#-----------------------------------------------------------------------
. ./build.sh

#-----------------------------------------------------------------------
# Finding Nek5000 repo:
# - First look in the machine directory
# - Then look in the NB_BENCH_DIR
# - If not found in the above places, clone from git
#-----------------------------------------------------------------------
nb_nek5_dir="$NB_BENCH_DIR/$nb_tag/Nek5000"
if [ -d "$nb_nek5_dir" ]; then
  iprint "Using existing Nek5000 directory: $nb_nek5_dir"
elif [ -d "$NB_BASE_DIR/Nek5000" ]; then
  iprint "Using existing Nek5000 directory: $NB_BASE_DIR/Nek5000"
  cp -r $NB_BASE_DIR/Nek5000  $nb_nek5_dir
else
  iprint "Cloning Nek5000 from github to $nb_nek5_dir"
  git clone https://github.com/Nek5000/Nek5000.git $nb_nek5_dir > git.log 2> git.error
  if [ ! -d "$nb_nek5_dir" ]; then
    iprint "Cloning failed. See git.error. Exitting ..." 1
    $NB_EXIT_CMD
  fi
fi

#-----------------------------------------------------------------------
# Run the case with the tag
#-----------------------------------------------------------------------
. ./bench.sh $nb_tag
