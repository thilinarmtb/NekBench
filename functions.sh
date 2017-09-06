#!/bin/sh

function abs() {
  local in="${1}"

  if [ $in -lt 0 ]; then
    in=$(( -1 * in ))
  fi

  echo $in
}

function max() {
  local arg_list=("${@}")
  local max=0

  for elem in "${arg_list[@]}"; do
    if [ $elem -gt $max ]; then
      max=$elem
    fi
  done

  echo $max
}

function test_max()
{
  local a=(-1 0 2 -3 5 2 -7)
  local rslt=$(max "${a[@]}")

  if [ $rslt = 5 ]; then
    echo "max: Passed. Result=${rslt}"
  else
    echo "max: Failed. Result=${rslt}"
  fi 
}
