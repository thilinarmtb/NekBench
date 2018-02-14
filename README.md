## NekBench - Scripts for benchmarking Nek5000

(Documentation is outdated, will be updated soon.)

### Introduction

This repository contains scripts for benchmarking
[Nek5000](https://nek5000.mcs.anl.gov/), a fast and scalable open-source
spectral element solver for CFD in different platforms from normal linux
desktop and laptop machines to super computers at ALCF, NERSC, etc. This
is written using bash scripting language and should run without any
problem on any Unix-like operating system which supports bash.

### Setting up the repository

You can clone the git repository directly using `git`:
```bash
git clone https://github.com/thilinarmtb/NekBench.git
```
or you can download the repository as a zip archive by clicking the
`clone or download` button in this page.

### Running benchmarks

Main script used in benchmarking is the ``go.sh`` which can be found on
the source root of the repository. If you run ``./go.sh --help`` or
``./go.sh -h``, it will print out a basic help message describing all
the parameters that can be passed into the ``go.sh`` script.

```
go.sh [options]

options:
   -h|--help                 Print this usage information and exit
   -t|--tag name             Specify a tag for the run (unique identifier)
                                 (e.g., scaling, pingpong,...; Default: scaling)
   -m|--machine machine_name Specify a machine for the run
                                 (Mandatory, e.g., linux, theta, cetus, ..)
   -x|--lx1 \"<list>\"         Specify a list of lx1 values for the run
                                 (Mandatory, e.g., \"3 4 5 6\")
   -y|--ly1 \"<list>\"         Specify a list of ly1 values for the run
                                 (Optional, Default: lx1 list)
   -z|--lz1 \"<list>\"         Specify a list of lz1 values for the run
                                 (Optional, Default: lx1 list)
   -e|--lelt \"<list>\"        Specify a list of lelt values for the run
                                 (Mandatory, e.g., \"128 256\")
   -n|--np \"<list>\"          Specify a list of MPI ranks for the run
                                 (e.g., \"2 4 8\"; Default: 1)
   -p|--ppn \"<list>\"         Specify a list of MPI ranks per node for the run
                                 (e.g., \"2 4 8\"; Default: 1)
   -c|--case case_name       Specify the path of the case to be used
                                 in benchmarking (e.g.,/home/nek_user/cases/box)
   --plot plot_type          Plot the benchmark data using matplotlib
                                 (plot_type can be scaling, ping_pong, etc.)
   --even-lxd                Round down lxd to an even value
   clean                     Clean the benchmark directory
```

Below is an example usage of the ``go.sh`` script:

```sh
./go.sh -t run1 -m "linux" -x "6" -e "100" -n "2 4 8" -p "2 4 8" -c "/home/foo/NekTests/eddy_uv"
```
Note that all the parameters can be lists except `-t / --tag`,
`-m / --machine` and `-c / --case`. See [1] under section `Notes` for
an explanation why this is.

Once this command is executed, it will create a benchmark run under a
folder named ``benchmarks``. The directory structure will look like
follows:

```
├── AUTHORS
├── benchmarks
│   └── run1
│       ├── linux
│       │   ├── lelt_100
│       │   │   ├── lx_6
│       │   │   │   └── eddy_uv
│       │   │   └── lx_8
│       │   │       └── eddy_uv
│       │   ├── lelt_200
│       │   │   ├── lx_6
│       │   │   │   └── eddy_uv
│       │   │   └── lx_8
│       │   │       └── eddy_uv
│       │   └── README
│       └── Nek5000
│           ├── 3rd_party
│           │
.
.
├── bench.sh
├── build.sh
├── functions.sh
├── go.sh
├── jobscripts
│   ├── bgq.submit
│   ├── cori.haswell.submit
.   .
│   └── theta.submit
├── machines
│   ├── bgq
│   ├── cori.haswell
.   .
│   └── theta
├── makeneks
│   ├── bgq.makenek
│   ├── cori.haswell.makenek
.   .
│   └── theta.makenek
├── plot.sh
├── README.md
└── scaling_plots.py

```
Under the `benchmarks` directory, there will be a directory named after
your tag. Then there will be a directory named after your machine parameter
under the `tag` directory.

Under each machine directory, there will be a separate directory for
each value in the `lelt` list. Similarly, under each of these `lelt`
directories, there will be a separate directory for each `lx1` value
(Currently, `ly1`, and `lz1` list values are ignored) and the case
specified in the script will be copied inside these lower level `lx1`
directories.

Finally, when the benchmarks are run, this case will be run for all the
values in the `np` list with appropriate `ppn` value from `ppn` list if
`ppn` is set. Otherwise, machine specific `ppn` value set in
`machines/<machine>` will be used.

Currently, NekBench has been succesfully tested on linux laptops/desktops,
ALCF Theta, NeRSC cori (KNL and Haswell) and NeRSC Edison machines.
Machine (`-m / --machine`) parameter for each of the previous machines
are `linux`, `theta`, `cori.knl / cori.haswell` and `edison` respectively.

### Important notes (must read before using the script !)

- Case directory name and the case name inside it should be the same i.e., if your
  case directory is `/home/foo/eddy`, then there should be `eddy.usr`, `eddy.rea`
  and `eddy.map` inside that directory.
- When the `go.sh` script is run, `makenek` file for the given machine is searched inside `makeneks`
  directory and the job submission script is searched inside `jobscripts` directory.
- For example, if you specified `-m "linux"`, `makeneks/makenek.linux` is used for building the
  given case and `jobscripts/submit.linux` is used for running (or submitting, if the machine uses
  job submission system) the case.
- Normally, you don't have to change these files. But if you need specific flags in the `makenek`
  file, feel free to edit.
- Each `submit.<machine>` script takes three arguments. These are fed automatically by the `go.sh`
  script. These arguments are different for each machine and depends on the job submission sustem
  each machine uses (I will add more documentation on these submission files). For each machine,
  these arguments are created using the file in `machines/<machine>`. For example, for `linux`
  machines, these arguments are created inside `machines/linux`.

### Developer documentation

- Names of the constants used in the scripts starts with `NB_` and variable
  names start with `nb_`. If you add new constants/variables, try to follow
  this standard.
- `functions.sh` - is the place to put functions if you end up reusing them again
  and again.
- `build.sh` - creates the directory structure for a particular benchmark run depending
  on the parameters given to `go.sh` script.
- `scaling.sh / pingpong.sh` - contains logic for scaling and ping-pong benchmarks.

### Caveats

- `lx1`, `lelt`, `lp`, `lpmin`, `lpmax` and `lxd` in your case's `SIZE` file should have integer
  expressions initializing them i.e., you can't have something like `parameter(lelt=lelg/lpmin + 4)`,
  If this is the case, sed substitution fails (We will support these expressions in future).

### Notes

1. Since, tag value is used as the unique identifier for a run within a
   machine, it does not make sense to have multiple tag values. Also,
   NekBench is run only in a single machine so it does not make sense to
   have multiple machine parameters as well.
