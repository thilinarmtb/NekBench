#-----------------------------------------------------------------------
# absolute value function
#-----------------------------------------------------------------------
function abs() {
  local in="${1}"

  if [ $in -lt 0 ]; then
    in=$(( -1*in ))
  fi

  echo $in
}

function test_abs() {
  local rslt1=$(abs -5)
  local rslt2=$(abs 5)

  if [ $rslt1 -eq 5 ] && [ $rslt2 -eq 5 ]; then
    echo "abs: Passed. Result=${rslt1}"
  else
    echo "abs: Failed. Result=${rslt1}"
  fi
}

#-----------------------------------------------------------------------
# max function
#-----------------------------------------------------------------------
function max() {
  local arg_list=("${@}")
  local out=0

  for elem in "${arg_list[@]}"; do
    if [ $elem -gt $out ]; then
      out=$elem
    fi
  done

  echo $out
}

function test_max()
{
  local a=(1 2 3 7 2 5)
  local rslt=$(max "${a[@]}")

  if [ $rslt -eq 7 ]; then
    echo "max: Passed. Result=${rslt}"
  else
    echo "max: Failed. Result=${rslt}"
  fi
}

#-----------------------------------------------------------------------
# min function
#-----------------------------------------------------------------------
function min() {
  local arg_list=("${@}")
  local out="${arg_list[0]}"

  for elem in "${arg_list[@]}"; do
    if [ $elem -lt $out ]; then
      out=$elem
    fi
  done

  echo $out
}

function test_min()
{
  local a=(2 3 5 2 7 1)
  local rslt=$(min "${a[@]}")

  if [ $rslt -eq 1 ]; then
    echo "min: Passed. Result=${rslt}"
  else
    echo "min: Failed. Result=${rslt}"
  fi
}

#-----------------------------------------------------------------------
# get_cur_run_dir function
#-----------------------------------------------------------------------
function get_cur_run_dir()
{
  local dir_list=($(ls | grep ${NB_RUN_DIR_PREFIX} 2> /dev/null))

  if [ -z "${dir_list}" ]; then # no previous runs
    echo "Error: No run directories found, exitting ..."
    $NB_EXIT_CMD
  else
    local n=${#dir_list[@]}
    echo ${dir_list[$((n - 1))]}
  fi
}

#-----------------------------------------------------------------------
# create_next_run_dir function
#-----------------------------------------------------------------------
function create_next_run_dir()
{
  local dir_list=($(ls | grep ${NB_RUN_DIR_PREFIX} 2> /dev/null))
  local dir_name=""

  if [ -z "${dir_list}" ]; then # no previous runs
    printf -v dir_name "${NB_RUN_DIR_PREFIX}%0${NB_RUN_DIR_NUM_LEN}d" 0
  else
    dir_name=$(get_cur_run_dir)
    local number=${dir_name: $(( -1*NB_RUN_DIR_NUM_LEN )) }
    number=$(( number + 1 ))
    printf -v dir_name "${NB_RUN_DIR_PREFIX}%0${NB_RUN_DIR_NUM_LEN}d" $number
  fi

  mkdir $dir_name
  echo $dir_name
}

#-----------------------------------------------------------------------
# dump_metadata function
#-----------------------------------------------------------------------
function dump_metadata()
{
  local git_sha=$(cd $nb_nek5_dir; git rev-parse HEAD; cd - >/dev/null)

  echo "case: ${nb_case_basename}" >> $NB_README_FILE
  echo "git_commit: ${git_sha[0]}" >> $NB_README_FILE
  echo "lelt: ${nb_lelt_list[@]}"  >> $NB_README_FILE
  echo "lx1: ${nb_lx1_list[@]}"    >> $NB_README_FILE
  echo "np: ${nb_np_list[@]}"      >> $NB_README_FILE
  echo "ppn: ${nb_ppn_list[@]}"    >> $NB_README_FILE
}

#-----------------------------------------------------------------------
# print function
#-----------------------------------------------------------------------
function iprint()
{
  local msg=$1
  local indntlvl=

  if [ $# -eq 2 ]; then
    indntlvl=$2
  else
    indntlvl=0
  fi

  if [ $indntlvl -eq 0 ]; then
    echo $msg
  elif [ $indntlvl -eq 1 ]; then
    sed -e "s/^/  /g" <<< ${msg}
  elif [ $indntlvl -eq 2 ]; then
    sed -e "s/^/    /g" <<< ${msg}
  elif [ $indntlvl -eq 3 ]; then
    sed -e "s/^/      /g" <<< ${msg}
  fi
}

#-----------------------------------------------------------------------
# Test functions
#-----------------------------------------------------------------------
if [ ${nb_test_functions} = true ]; then
  test_abs
  test_max
  test_min
fi
