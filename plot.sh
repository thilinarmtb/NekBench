#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - Three inputs: machine, tag and plot type
#-----------------------------------------------------------------------
nb_plt_type="$1"
nb_plt_tagdir="$NB_BENCH_DIR/${nb_machine}/${nb_tag}"

nb_plt_readme="${nb_plt_tagdir}/README"
readarray a < "${nb_plt_readme}"

nb_plt_lx1=
nb_plt_lelt=
nb_plt_case=
nb_plt_np=

for index in ${!a[@]}; do
  line=(${a[$index]})
  name=${line[0]: :-1}
  value=${line[@]:1}

  case "${name}" in
    lx1)
      nb_plt_lx1="${value}"
      ;;
    lelt)
      nb_plt_lelt="${value}"
      ;;
    case)
      nb_plt_case="${value}"
      ;;
    np)
      nb_plt_np="${value}"
      ;;
  esac
done

for lelt in ${nb_plt_lelt[@]}; do
  for lx in ${nb_plt_lx1[@]}; do
    nb_plt_logprfx="${nb_plt_case}.log.${nb_tag}."
    nb_plt_logpath="${nb_plt_tagdir}/lelt_${lelt}/lx_${lx}/${nb_plt_case}/"
    cd ${nb_plt_logpath}
      rm ${NB_TIME_DATA} 2>/dev/null

      for np in ${nb_plt_np[@]}; do
        logfile="${nb_plt_logprfx}${np}"
        echo $logfile
        tmp=($(grep "total solver time w/o IO" ${logfile}*))
        echo ${tmp[6]} >> ${NB_TIME_DATA}
      done

    cd - > /dev/null
  done
done

if [ $nb_plt_type = "scaling" ]; then
  python scaling_plots.py --lx       $nb_plt_lx1  \
                          --lelt     $nb_plt_lelt \
                          --np       $nb_plt_np   \
                          --machine  $nb_machine  \
                          --tag      $nb_tag      \
                          --case     $nb_plt_case \
                          --directory $NB_BENCH_DIR \
                          --data_file $NB_TIME_DATA
fi
#echo "$nb_plt_lx1"
#echo "$nb_plt_lelt"
#echo "$nb_plt_case"
#echo "$nb_plt_np"
