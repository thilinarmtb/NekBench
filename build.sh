#-----------------------------------------------------------------------
# Create tag directory
#-----------------------------------------------------------------------
mkdir -p $NB_BENCH_DIR/$nb_tag 2> /dev/null
cd $NB_BENCH_DIR/$nb_tag

iprint "Building directory structure ..."

#-----------------------------------------------------------------------
# See if the directory for the machine exist
#-----------------------------------------------------------------------
if [ -d $nb_machine ]; then
  iprint "Directory for the given machine already exist. Exitting ..."
  $NB_EXIT_CMD
fi

mkdir $nb_machine
cd $nb_machine

#-----------------------------------------------------------------------
# Create the rest of directory hierarchy
#-----------------------------------------------------------------------
for lelt in ${nb_lelt_list[@]}; do
  mkdir lelt_"${lelt}" 2>/dev/null
  cd lelt_"${lelt}"
  for lx1 in ${nb_lx1_list[@]}; do
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

cd $NB_BASE_DIR
