iprint "Building directory structure ..."

#-----------------------------------------------------------------------
# Create tag directory
#-----------------------------------------------------------------------
mkdir -p $NB_BENCH_DIR/$nb_tag 2> /dev/null
cd $NB_BENCH_DIR/$nb_tag

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
dbg_count=0
for i in ${!NB_PAR[@]}; do
for j in ${!NB_PAR[@]}; do
  par_i=(${NB_PAR[$i]})
  par_j=(${NB_PAR[$j]})
# echo "par_i = ${par_i[@]}"
# echo "par_j = ${par_j[@]}"
  if [ "$i" -ne "$j" ] && [ $i -lt $j ]; then
    nb_par_i_id=${par_i[0]}
    nb_par_i_vals=(${par_i[@]:1})
    nb_par_j_id=${par_j[0]}
    nb_par_j_vals=(${par_j[@]:1})
    for i_val in ${nb_par_i_vals[@]}; do
    for j_val in ${nb_par_j_vals[@]}; do
    (( dbg_count += 1 ))
#     echo "ijpar ${nb_par_i_id} ${nb_par_j_id}"
#     echo "ijval ${i_val} ${j_val}"
#     echo "ij $i $j"
      dir="p_${nb_par_i_id}_${i_val}_${nb_par_j_id}_${j_val}"
      mkdir "${dir}"
      cd "${dir}"
      cp -r "${nb_case}" .
      cd $nb_case_basename
      sed -i.bu "$((nb_par_i_id+4))s/^ *\S*/${i_val}/" *.rea
      sed -i.bu "$((nb_par_j_id+4))s/^ *\S*/${j_val}/" *.rea
      cd ..
      cd ..
    done
    done
  fi
done
done

echo "count = $dbg_count"

cd $NB_BASE_DIR
