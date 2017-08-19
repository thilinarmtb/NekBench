#!/bin/bash

# What do you want to do?
#       nodewise performance?
#       internode communication?
#       intranode-communication?
#       platform timer? mxm_tests? comm_tests?

# lx1 range
# lelt range
# lp range
# machine

lx1_list=
ly1_list=
lz1_list=
lelt_list=
lp_list=
machine_list=

this_file="${BASH_SOURCE[0]}"

## Read input arguments
while [ $# -gt 0 ]; do
  case "$1" in
         -x|--lx1)
           shift
           lx1_list=$1
           ;;
         -y|--ly1)
           shift
           ly1_list=$1
           ;;
         -z|--lz1)
           shift
           lz1_list=$1
           ;;
         -e|--lelt)
           shift
           lelt_list=$1
           ;;
         -p|--lp)
           shift
           lp_list=$1
           ;;
         -m|--machine)
           shift
           machine_list=$1
           ;;
  esac
  shift
done # end reading arguments

echo "lx1 = $lx1_list"
echo "ly1 = $ly1_list"
echo "lz1 = $lz1_list"
echo "lelt = $lelt_list"
echo "lp = $lp_list"
echo "machine = $machine_list"
