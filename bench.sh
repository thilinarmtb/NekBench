printf "================ Benchmark Run: $nb_tag ================\n"
printf "case name : ${nb_case_basename}\n"
printf "Nek5000   : ${nb_nek5_dir}\n"
printf "makenek   : ${nb_nek5_dir}/bin/makenek\n"
printf "submit    : ${NB_JOBS_DIR}/${nb_machine}.submit\n"

# cd to the test dir
cd $NB_BENCH_DIR/$nb_tag/$nb_machine

for lelt in ${nb_lelt_list[@]}; do
  cd lelt_"${lelt}"
  for lx1 in ${nb_lx1_list[@]}; do
    cd lx_"${lx1}"
      cd $nb_case_basename
        iprint "Building lelt=${lelt}, lx1=${lx1} ..." 1

        # Copy the makenek and update it for the machine
        cp ${nb_nek5_dir}/bin/makenek .
        . $NB_BASE_DIR/makenek.sh `pwd`/makenek

        # Clean if a previous build exist
        iprint "Cleaning existing build ..." 2
        printf "y\n" | ./makenek clean > clean.log 2> clean.error
        iprint "Cleaning successful." 3

        # Build the case
        iprint "Building the case ..." 2
        ./makenek $nb_case_basename > build.log 2> build.error

        if [ ! -f ./nek5000 ]; then
          iprint "Build failed. See 'build.error'. Exitting ..." 3
          printf "====================================================="
          $NB_EXIT_CMD
        fi
        iprint "Build successful." 3

        iprint "Submitting the jobs ..." 2
        if [ $nb_ppn_set = false ]; then
          for nb_np in ${nb_np_list[@]}; do
            . ${NB_MCHN_DIR}/${nb_machine}
            iprint "Submitting the case with np=${nb_np} ppn=${nb_ppn}..." 3
            ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit \
                           ${nb_case_basename} ${nb_tag} ${nb_np} ${nb_ppn}
          done
        else
          index=0
          for nb_np in ${nb_np_list[@]}; do
            nb_ppn=${nb_ppn_list[$index]}
            . ${NB_MCHN_DIR}/${nb_machine}
            iprint "Submitting the case with np=${nb_np} ppn=${nb_ppn}..." 3
            ${NB_RUN_CMD} ${NB_JOBS_DIR}/${nb_machine}.submit \
                           ${nb_case_basename} ${nb_tag} ${nb_np} ${nb_ppn}
            index=$(( index + 1 ))
          done
        iprint "Submitting successful." 3
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
