#!/bin/sh

echo " ================ Doing Scaling Test ================ "
echo " case name: ${case_basename}"
echo " ==================================================== "

cd $RUNS_DIR/$case_basename/scaling

for lelt in $lelt_list; do
  cd lelt_"${lelt}"
  for lx1 in $lx1_list; do
    cd lx_"${lx1}"
      cd $case_basename
        cp $BASE_DIR/makeneks/makenek.${machine} .
##      build and run
      cd ..
    cd ..
  done
  cd ..
done


cd $BASE_DIR
