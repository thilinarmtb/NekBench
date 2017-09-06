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
          sed -i "s/lx1=[0-9]*/lx1=${lx1}/" SIZE
          sed -i "s/lxd=[0-9]*/lxd=${lxd}/" SIZE
          sed -i "s/lelt=[0-9]*/lelt=${lelt}/" SIZE
          sed -i "s/lpmin=[0-9]*/lpmin=${lp_min}/" SIZE
          sed -i "s/lpmax=[0-9]*/lpmax=${lp_max}/" SIZE
        cd ..
      cd ..
    done
    cd ..
  done
  
  cd ..
done

cd ../..
