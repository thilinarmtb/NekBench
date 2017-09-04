#!/bin/sh

size=${#test_list[@]}
size=$(( size - 1 ))
echo $size

first_test=${test_list[0]}
cd cases/$case_basename/$first_test

for lelt in $lelt_list; do
   mkdir lelt_"${lelt}"
   cd lelt_"${lelt}"
   for lx1 in $lx1_list; do
      mkdir lx_"${lx1}" 
      cd lx_"${lx1}" 
      cd ..
   done
   cd ..
done

cd ..

for i in `seq 1 1 $size`; do
  echo $i
done

