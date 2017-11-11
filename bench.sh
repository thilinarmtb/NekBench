iprint "================ Benchmark Run: $nb_tag ================ "
iprint "case name      : ${nb_case_basename}"
iprint "Nek5000        : ${nb_nek5_dir}"
iprint "makenek script : ${NB_MKNK_DIR}/${nb_machine}.makenek"
iprint "submit script  : ${NB_JOBS_DIR}/${nb_machine}.submit"

# Get rid of this export and matching unset
export nb_nek5_dir

# cd to the test dir
cd $NB_BENCH_DIR/$nb_tag/$nb_machine

for lelt in ${nb_lelt_list[@]}; do
  cd lelt_"${lelt}"
  for lx1 in ${nb_lx1_list[@]}; do
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
          iprint "====================================================="
          $NB_EXIT_CMD
        fi

        iprint "Build successful ..." 2
        if [ $nb_ppn_set = false ]; then
          for nb_np in ${nb_np_list[@]}; do
            . ${NB_MCHN_DIR}/${nb_machine}
            iprint "Running the case with np=${nb_np} ppn=${nb_ppn}..." 2
            ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit \
                           ${nb_case_basename} ${nb_tag} ${nb_np} ${nb_ppn}
          done
        else
          index=0
          for nb_np in ${nb_np_list[@]}; do
            nb_ppn=${nb_ppn_list[$index]}
            . ${NB_MCHN_DIR}/${nb_machine}
            iprint "Running the case with np=${nb_np} ppn=${nb_ppn}..." 2
            ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit \
                           ${nb_case_basename} ${nb_tag} ${nb_np} ${nb_ppn}
            index=$(( index + 1 ))
          done
        fi
      cd ..
    cd ..
  done
  cd ..
done

# Dump the benchmark metadata to a README file inside the tag directory
dump_metadata

iprint "====================================================="

cd $NB_BASE_DIR

unset nb_nek5_dir
