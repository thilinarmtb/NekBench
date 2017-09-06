#!/bin/sh

function abs() {
  local in="${1}"

  if [ $in -lt 0 ]; then
    in=$(( -1 * in ))
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
test_abs

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
  local a=(1 2 3 7 2 5)
  local rslt=$(max "${a[@]}")

  if [ $rslt -eq 7 ]; then
    echo "max: Passed. Result=${rslt}"
  else
    echo "max: Failed. Result=${rslt}"
  fi 
}
test_max

function min() {
  local arg_list=("${@}")
  local min="${arg_list[0]}"

  for elem in "${arg_list[@]}"; do
    if [ $elem -lt $min ]; then
      min=$elem
    fi
  done

  echo $min
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
test_min
