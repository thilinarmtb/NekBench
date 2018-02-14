#!/bin/sh

nb_makenek="$1"

# Read machine specific data: compilers, flags, etc.
source ${NB_MCHN_DIR}/${nb_machine}

sed -i.bak -e "s|^#FC=.*|FC=\"${nb_fc}\"|" \
           -e "s|^#F77=.*|F77=\"${nb_fc}\"|" \
           -e "s|^#CC=.*|CC=\"${nb_cc}\"|" \
           -e "s|^#SOURCE_ROOT=.*|SOURCE_ROOT=\"${nb_nek5_dir}\"|" \
           -e "s|^#FFLAGS=.*|FFLAGS=\"${nb_fflags}\"|" \
           -e "s|^#CFLAGS=.*|CFLAGS=\"${nb_cflags}\"|" \
           -e "s|^#USR_LFLAGS+=.*|USR_LFLAGS+=\"${nb_usr_lflags}\"|" ${nb_makenek}
