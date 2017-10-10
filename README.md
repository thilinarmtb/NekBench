## NekBench - Scripts for benchmarking Nek5000 (Outdated, will be updated soon)
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
repository. If you run ``./go.sh --help`` or ``go.sh -h``, it will print out a basic help message
describing all the parameters that can be passed into the ``go.sh`` script.

```
go.sh [options]

options:
   -h|--help                 Print this usage information and exit
   -x|--lx1 "<list>"         Specify a list of lx1 values for the run
                               (Mandatory, e.g., "3 4 5 6")
   -y|--ly1 "<list>"         Specify a list of ly1 values for the run
                               (Optional, Default: lx1 list)
   -z|--lz1 "<list>"         Specify a list of lz1 values for the run
                               (Optional, Default: lx1 list)
   -e|--lelt "<list>"        Specify a list of lelt values for the run
                               (Mandatory, e.g., "128 256")
   -n|--np "<list>"          Specify a list of MPI ranks for the run
                               (e.g., "2 4 8"; Default: 1)
   -m|--machine machine_name Specify a machine for the run
                               (Mandatory, e.g., theta, cetus, ..)
   -t|--test "<list>"        Specify a list of tests to be run
                               (e.g., scaling, pingpong,...; Default: scaling)
   -c|--case case_name       Specify the path of the case to be used
                               in benchmarking (e.g.,/home/nek_user/cases/box)
   --even-lxd                Round down lxd to an even value
```

Below is an example usage of the ``go.sh`` script:

```sh
./go.sh -x "6 7" -e "100 200" -n "4 8" -m "linux" -t "scaling" -c "/home/foo/NekTests/eddy_uv"
```
Once this command is executed, it will create a benchmark run for a scaling study under a
folder named ``runs``. Note that all the parameters are lists except `-m / --machine` and
`-c / --case`. The directory structure will look like follows:

```
.
├── build.sh
├── go.sh
.
.
├── README.md
├── runs
│   └── linux
│       └── scaling
│           ├── lelt_100
│           │   ├── lx_6
│           │   │   └── eddy_uv
│           │   └── lx_7
│           │       └── eddy_uv
│           └── lelt_200
│               ├── lx_6
│               │   └── eddy_uv
│               └── lx_7
│                   └── eddy_uv
└── scaling.sh
```
Under the `runs` directory, there will be a directory named after your `case`. In the case of
a ping-pong test, a built-in case called `pngpng` will be created. Under the `case` directory,
a separate directory will be created for each value in `test` list. Since we only specified
`scaling` in the test list, we only see one directory here (May be creating a separate directory
for each test is not necessary, we will figure that out when we start using this for real
benchmarks).

Under each test directory, there will be a separate directory for each value in the `lelt`
list. Similarly, under each of these `lelt` directories, there will be a separate directory for
each `lx1` value (Currently, `ly1`, and `lz1` list values are ignored) and the case specified
in the script will be copied inside of this directory. Finally, when the benchmarks are run,
for a scaling test, each of these low level cases are run for all the values in the `np` list.

Currently, NekBench has been succesfully tested on linux laptops/desktops, ALCF Theta, NeRSC cori
(KNL and Haswell) and NeRSC Edison machines for `scaling` tests. Machine (`-m / --machine`) parameter
for each of the previous machines are `linux`, `theta`, `cori.knl / cori.haswell` and `edison`
respectively.

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
