cd $NB_RUNS_DIR/$nb_case_basename

for tst in $nb_test_list; do
  mkdir $tst 2>/dev/null
  cd $tst

  for lelt in $nb_lelt_list; do
    mkdir lelt_"${lelt}" 2>/dev/null
    cd lelt_"${lelt}"
    for lx1 in $nb_lx1_list; do
      mkdir lx_"${lx1}" 2>/dev/null
      cd lx_"${lx1}"
        cp -r "${nb_case}" .
        cd $nb_case_basename
          lxd=$(( 3*lx1/2 ))
          sed -i.backup "s/lx1[\s]*=[\s]*[0-9]*/lx1=${lx1}/" SIZE
          sed -i.backup "s/lxd[\s]*=[\s]*[0-9]*/lxd=${lxd}/" SIZE
          sed -i.backup "s/lelt[\s]*=[\s]*[0-9]*/lelt=${lelt}/" SIZE
          sed -i.backup "s/lpmin[\s]*=[\s]*[0-9]*/lpmin=${nb_lp_min}/" SIZE
          sed -i.backup "s/lpmax[\s]*=[\s]*[0-9]*/lpmax=${nb_lp_max}/" SIZE
          sed -i.backup "s/lp[\s]*=[\s]*[0-9]*/lp=${nb_lp_max}/" SIZE
        cd ..
      cd ..
    done
    cd ..
  done

  cd ..
done

cd $NB_BASE_DIR
