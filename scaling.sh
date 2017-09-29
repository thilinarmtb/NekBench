echo "================ Doing Scaling Test ================ "
echo "case name      : ${nb_case_basename}"
echo "Nek5000        : ${NB_NEK5_DIR}"
echo "makenek script : ${NB_MKNK_DIR}/${nb_machine}.makenek"
echo "submit script  : ${NB_JOBS_DIR}/${nb_machine}.submit"

# Get rid of this export and matching unset
export NB_NEK5_DIR

cd $NB_RUNS_DIR/$nb_machine/scaling

for lelt in $nb_lelt_list; do
  cd lelt_"${lelt}"
  for lx1 in $nb_lx1_list; do
    cd lx_"${lx1}"
      cd $nb_case_basename
        # Build the case
        echo "  Building lelt=${lelt}, lx1=${lx1} ..."
        cp $NB_MKNK_DIR/${nb_machine}.makenek .
        ./${nb_machine}.makenek $nb_case_basename > build.log 2>build.error

        if [ ! -f ./nek5000 ]; then
          echo "    Building failed. See 'build.error'. Exitting ..."
          echo "==================================================== "
          $NB_EXIT_CMD
        fi
        # Do the scaling test
        for nb_np in $nb_np_list; do
          . ${NB_MCHN_DIR}/${nb_machine}
          echo "    Running the case with np=${nb_np} ..."
          ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit ${nb_case_basename} scaling ${nb_np} ${nb_ppn}
        done
      cd ..
    cd ..
  done
  cd ..
done

echo "==================================================== "

cd $NB_BASE_DIR

unset NB_NEK5_DIR
