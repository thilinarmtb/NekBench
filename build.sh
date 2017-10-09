cd $NB_BENCH_DIR/$nb_machine

echo "Building directory structure ..."

for tst in $nb_test_list; do
  # Create test directory if it does not exist
  mkdir $tst 2>/dev/null
  cd $tst

  # Create next run directory
  nb_run_dir_name=$(create_next_run_dir)
  cd $nb_run_dir_name

  for lelt in $nb_lelt_list; do
    mkdir lelt_"${lelt}" 2>/dev/null
    cd lelt_"${lelt}"
    for lx1 in $nb_lx1_list; do
      mkdir lx_"${lx1}" 2>/dev/null
      cd lx_"${lx1}"
        cp -r "${nb_case}" .
        cd $nb_case_basename
          lxd=$(( 3*lx1/2 ))
          if [ ${nb_even_lxd} = true ]; then
            lxd=$(( $lxd - ($lxd % 2) ))
          fi
          perl -pe "s/lx1=.*?(?=(,|\)))/lx1=${lx1}/" SIZE      | \
          perl -pe "s/lxd=.*?(?=(,|\)))/lxd=${lxd}/"           | \
          perl -pe "s/lelt=.*?(?=(,|\)))/lelt=${lelt}/"        | \
          perl -pe "s/lpmin=.*?(?=(,|\)))/lpmin=${nb_lp_min}/" | \
          perl -pe "s/lpmax=.*?(?=(,|\)))/lpmax=${nb_lp_max}/" | \
          perl -pe "s/lp=.*?(?=(,|\)))/lp=${nb_lp_max}/"       > nb.SIZE
          mv nb.SIZE SIZE
        cd ..
      cd ..
    done
    cd ..
  done

  ## Get out of run directory
  cd ..
  ## Get out of test directory
  cd ..
done

cd $NB_BASE_DIR
