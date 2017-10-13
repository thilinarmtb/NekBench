#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - Three inputs: machine, tag and plot type
#-----------------------------------------------------------------------
nb_plt_machine="$1"
nb_plt_tag="$2"
nb_plt_type="$3"

nb_plt_readme="$NB_BENCH_DIR/${nb_plt_machine}/${nb_plt_tag}/README"
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

echo "$nb_plt_lx1"
echo "$nb_plt_lelt"
echo "$nb_plt_case"
echo "$nb_plt_np"
