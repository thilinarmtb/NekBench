#!/bin/sh

echo "================ Doing Scaling Test ================ "
echo "case name: ${nb_case_basename}"

cd $NB_RUNS_DIR/$nb_case_basename/scaling

for lelt in $nb_lelt_list; do
  cd lelt_"${lelt}"
  for lx1 in $nb_lx1_list; do
    cd lx_"${lx1}"
      cd $nb_case_basename
        # Build the case
        echo "  Building lelt=${lelt}, lx1=${lx1} ..."
        cp $NB_MKNK_DIR/makenek.${nb_machine} .
        ./makenek.${nb_machine} $nb_case_basename > buildlog

        # Do the scaling test
        for np in $nb_np_list; do
          echo "    Running the case with np=${np} ..."
          $NB_JOBS_DIR/submit.${nb_machine} ${nb_case_basename} ${np} scaling
        done
      cd ..
    cd ..
  done
  cd ..
done

echo "==================================================== "

cd $NB_BASE_DIR
