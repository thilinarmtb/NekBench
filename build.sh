#!/bin/sh

cd cases/$case_basename

for tst in $test_list; do
  mkdir $tst
  cd $tst
  for lelt in $lelt_list; do
    mkdir lelt_"${lelt}"
    cd lelt_"${lelt}"
    for lx1 in $lx1_list; do
      mkdir lx_"${lx1}"
      cd lx_"${lx1}"
        cp -r "${case}" .
        cd $case_basename
          lxd=$(( 3*lx1/2 ))
          sed "s/lx1=[0-9]*/lx1=${lx1}/" SIZE > SIZE.1
          sed "s/lxd=[0-9]*/lxd=${lxd}/" SIZE.1 > SIZE.2
          sed "s/lelt=[0-9]*/lelt=${lelt}/" SIZE.2 > SIZE.3
          rm SIZE.1 SIZE.2
          mv SIZE.3 SIZE
        cd ..
      cd ..
    done
    cd ..
  done
  
  cd ..
done

cd ..
