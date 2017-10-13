#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - Three inputs: machine, tag and plot type
#-----------------------------------------------------------------------
plt_machine="$1"
plt_tag="$2"
plt_type="$3"

nb_readme="$NB_BENCH_DIR/${plt_machine}/${plt_tag}/README"
readarray a < "${nb_readme}"

for index in ${!a}; do
 echo $index
done
