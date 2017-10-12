#-----------------------------------------------------------------------
# Plot the benchmark data:
#   - Three inputs: machine, test and runid
#-----------------------------------------------------------------------
plt_machine=$1
plt_test=$2
plt_runid=$3

nb_readme="$NB_BENCH_DIR/$plt_machine/$plt_test/$plt_runid/README"
count=0
while IFS= read -r line; do
    l=($l)
    echo "${l[@]:1}"
done < "$nb_readme"

#data=$(cat $nb_readme)
#data=(`echo $data | tr ":" "\n"`)
#echo $data
#IFS=':'; arrdata=( $data ); unset IFS;
