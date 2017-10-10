iprint "================ Doing Scaling Test ================ "
iprint "case name      : ${nb_case_basename}"
iprint "Nek5000        : ${NB_NEK5_DIR}"
iprint "makenek script : ${NB_MKNK_DIR}/${nb_machine}.makenek"
iprint "submit script  : ${NB_JOBS_DIR}/${nb_machine}.submit"

# Get rid of this export and matching unset
export NB_NEK5_DIR

cd $NB_RUNS_DIR/$nb_machine/scaling

for lelt in $nb_lelt_list; do
  cd lelt_"${lelt}"
  for lx1 in $nb_lx1_list; do
    cd lx_"${lx1}"
      cd $nb_case_basename
        # Build the case
        iprint "Building lelt=${lelt}, lx1=${lx1} ..." 1
        cp $NB_MKNK_DIR/${nb_machine}.makenek .
        iprint "Cleaning existing build ..." 2
        ./${nb_machine}.makenek realclean > clean.log 2> clean.error
        iprint "Building ..." 2
        ./${nb_machine}.makenek $nb_case_basename > build.log 2>build.error

        if [ ! -f ./nek5000 ]; then
          iprint "Build failed. See 'build.error'. Exitting ..." 2
          iprint "==================================================== "
          $NB_EXIT_CMD
        fi

        iprint "Build successful ..." 2
        # Do the scaling test
        for nb_np in $nb_np_list; do
          . ${NB_MCHN_DIR}/${nb_machine}
          iprint "Running the case with np=${nb_np} ..." 2
          ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit ${nb_case_basename} scaling ${nb_np} ${nb_ppn}
        done
      cd ..
    cd ..
  done
  cd ..
done

iprint "==================================================== "

cd $NB_BASE_DIR

unset NB_NEK5_DIR
