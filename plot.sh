#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - 1 input: plot type
#-----------------------------------------------------------------------
nb_plt_type="$1"

#-----------------------------------------------------------------------
# Variables that store metadata
#-----------------------------------------------------------------------
declare -A nb_plt_lx1
declare -A nb_plt_lelt
declare -A nb_plt_case
declare -A nb_plt_np

#-----------------------------------------------------------------------
# Read timing data
#-----------------------------------------------------------------------
for machine in ${nb_machine_list[@]}; do
  for tag in ${nb_tag_list[@]}; do
    # Find tag directory
    nb_plt_tagdir="$NB_BENCH_DIR/${machine}/${tag}"

    # Read metadata from README file in the tag directory
    nb_plt_readme="${nb_plt_tagdir}/$NB_README_FILE"
    readarray a < "${nb_plt_readme}"

    # Initialize variables for each machine
    nb_machine_plt_lx1=
    nb_machine_plt_lelt=
    nb_machine_plt_case=
    nb_machine_plt_np=

    for index in ${!a[@]}; do
      line=(${a[$index]})
      name=${line[0]: :-1}
      value=${line[@]:1}

      case "${name}" in
        lx1)
          nb_machine_plt_lx1="${value}"
          ;;
        lelt)
          nb_machine_plt_lelt="${value}"
          ;;
        case)
          nb_machine_plt_case="${value}"
          ;;
        np)
          nb_machine_plt_np="${value}"
          ;;
        ppn)
          nb_machine_plt_ppn="${value}"
          ;;
      esac
    done

    # Convert input lists to bash arrays
#    nb_machine_plt_lx1=(${nb_machine_plt_lx1})
#    nb_machine_plt_lelt=(${nb_machine_plt_lelt})
#    nb_machine_plt_case=(${nb_machine_plt_case})
#    nb_machine_plt_np=(${nb_machine_plt_np})
#    nb_machine_plt_ppn=(${nb_machine_plt_ppn})

    # Save in the global lists
    nb_plt_lx1[$machine]=${nb_machine_plt_lx1[@]}
    nb_plt_lelt[$machine]=${nb_machine_plt_lelt[@]}
    nb_plt_case[$machine]=${nb_machine_plt_case[@]}
    nb_plt_np[$machine]=${nb_machine_plt_np[@]}
    nb_plt_ppn[$machine]=${nb_machine_plt_ppn[@]}

    # Read data from log files
    for lelt in ${nb_plt_lelt[@]}; do
      for lx in ${nb_plt_lx1[@]}; do
        nb_plt_logprfx="${nb_plt_case}.log.${nb_tag}."
        nb_plt_logpath="${nb_plt_tagdir}/lelt_${lelt}/lx_${lx}/${nb_plt_case}/"
        cd ${nb_plt_logpath}
          rm ${NB_TIME_DATA} 2>/dev/null

          for index in ${!nb_plt_np[@]}; do
            np=(${nb_plt_np[$index]})
            ppn=(${nb_plt_ppn[$index]})
            logfile="${nb_plt_logprfx}${np}.${ppn}"

            tmp=($(grep "total solver time" ${logfile}*))
            echo ${tmp[6]} >> ${NB_TIME_DATA}
          done
        cd - > /dev/null
      done
    done
  done
done

#-----------------------------------------------------------------------
# Print debug information
#-----------------------------------------------------------------------
nb_debug_scripts=true
if [ ${nb_debug_scripts} = true ]; then
  echo "${nb_plt_lx1[@]}"
  echo "${nb_plt_lelt[@]}"
  echo "${nb_plt_case[@]}"
  echo "${nb_plt_np[@]}"
  echo "${nb_plt_ppn[@]}"
fi

#-----------------------------------------------------------------------
# Plot data
#-----------------------------------------------------------------------
if [ $nb_plt_type = "scaling" ]; then
  python scaling_plots.py --lx        ${nb_plt_lx1[@]}   \
                          --lelt      ${nb_plt_lelt[@]}  \
                          --np        ${nb_plt_np[@]}    \
                          --machine   ${nb_machine_list[@]}   \
                          --tag       ${nb_tag[@]}       \
                          --case      ${nb_plt_case[@]}  \
                          --directory ${NB_BENCH_DIR} \
                          --data_file ${NB_TIME_DATA}
fi
