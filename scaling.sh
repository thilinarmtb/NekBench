echo "================ Doing Scaling Test ================ "
echo "case name      : ${nb_case_basename}"
echo "Nek5000        : ${NB_NEK5_DIR}"
echo "makenek script : ${NB_MKNK_DIR}/makenek.${nb_machine}"
echo "submit script  : ${NB_JOBS_DIR}/submit.${nb_machine}"


cd $NB_RUNS_DIR/$nb_case_basename/scaling

export NB_NEK5_DIR # get rid of this export and matching unset

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
        for nb_np in $nb_np_list; do
          . ${NB_MCHN_DIR}/${nb_machine}
          echo "    Running the case with np=${nb_np} ..."
          ${NB_RUN_CMD} ${NB_JOBS_DIR}/submit.${nb_machine} ${nb_case_basename} scaling ${nb_arg3}
        done
      cd ..
    cd ..
  done
  cd ..
done

unset NB_NEK5_DIR

echo "==================================================== "

cd $NB_BASE_DIR
