## NekBench - Scripts for benchmarking Nek5000
### Introduction

This repository contains scripts for benchmarking [Nek5000](https://nek5000.mcs.anl.gov/), a fast and scalable open-source
spectral element solver for CFD in different platforms from normal linux desktop and laptop
machines to super computers at ALCF, NERSC, etc. This is written using bash scripting language
and should run without any problem on any Unix-like operating system which supports bash.

### Setting up the repository

You can clone the git repository directly using `git`:
```bash
git clone https://github.com/thilinarmtb/NekBench.git
```
or you can download the repository as a zip archive by clicking the `clone or download` button
in this page.

### Running benchmarks

Main script used in benchmarking is the ``go.sh`` which can be found on the source root of the
repository. If you run ``./go.sh --help``, it will print out a basic help message describing
all the parameters that can be passed into the ``go.sh`` script.
```sh
go.sh [options]

options:
   -h|--help                   Print this usage information and exit
   -x|--lx1 \"<list>\"         Specify a list of lx1 values for the run
                                 (Mandatory, e.g., \"3 4 5 6\")
   -y|--ly1 \"<list>\"         Specify a list of ly1 values for the run
                                 (Optional, Default: lx1 list)
   -z|--lz1 \"<list>\"         Specify a list of lz1 values for the run
                                 (Optional, Default: lx1 list)
   -e|--lelt \"<list>\"        Specify a list of lelt values for the run
                                 (Mandatory, e.g., \"128 256\")
   -n|--np \"<list>\"          Specify a list of MPI rank for the run
                                 (Mandatory, e.g., \"2 4 8\")
   -m|--machine \"machine\"    Specify a machine for the run
                                 (Mandatory, e.g., theta, cetus, ..)
   -t|--test \"<list>\"        Specify a list of tests to be run
                                 (Mandatory, e.g., scaling, pingpong,..)
   -c|--case \"case_name\"     Specify a case to be used in benchmarking
                                 (Use the full path of the case, e.g.,
                                   /home/nek_user/cases/box)
```

### Developer documentation

### Caveats
* Constants in Caps, variables in lowercase
* Case direcotry name and the case name should be the same
* lxd should have an integer expression, otherwise sed fails
