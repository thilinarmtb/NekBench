#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - Three inputs: machine, tag and plot type
#-----------------------------------------------------------------------
nb_plt_machine="$1"
nb_plt_tag="$2"
nb_plt_type="$3"
nb_plt_tagdir="$NB_BENCH_DIR/${nb_plt_machine}/${nb_plt_tag}"

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
    nb_plt_logprfx="${nb_plt_case}.log.${nb_plt_tag}."
    nb_plt_logpath="${nb_plt_tagdir}/lelt_${lelt}/lx_${lx}/${nb_plt_case}/"
    cd ${nb_plt_logpath}
      rm nprocs.nbdata time.nbdata

      for logfile in ${nb_plt_logprfx}*; do
        tmp=($(grep "Number of processors" $logfile))
        echo ${tmp[3]} >> nprocs.nbdata
        tmp=($(grep "total solver time w/o IO" $logfile))
        echo ${tmp[6]} >> time.nbdata
      done

    cd - > /dev/null
  done
done

#echo "$nb_plt_lx1"
#echo "$nb_plt_lelt"
#echo "$nb_plt_case"
#echo "$nb_plt_np"
