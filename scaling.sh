#!/bin/sh

echo " ================ Doing Scaling Test ================ "
echo " case name: ${case_basename}"

cd $RUNS_DIR/$case_basename/scaling

for lelt in $lelt_list; do
  cd lelt_"${lelt}"
  for lx1 in $lx1_list; do
    cd lx_"${lx1}"
      cd $case_basename
        # Build the case
        echo "Building lelt=${lelt}, lx1=${lx1}"
        cp $BASE_DIR/makeneks/makenek.${machine} .
        ./makenek.${machine} $case_basename > buildlog

        # Do the scaling test
        for np in $np_list; do
          echo "Running the case with np=${np}"
          $JOBS_DIR/submit.${machine} ${case_basename} ${np} scaling
        done
      cd ..
    cd ..
  done
  cd ..
done

echo " ==================================================== "

cd $BASE_DIR
