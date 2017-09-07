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
        # Build the case
        cp $BASE_DIR/makeneks/makenek.${machine} .
        ./makenek.${machine} $case_basename

        # Do the scaling test
        for np in $np_list; do
          $JOBS_DIR/submit.${machine} ${case_basename} ${np}
        done
      cd ..
    cd ..
  done
  cd ..
done

cd $BASE_DIR
