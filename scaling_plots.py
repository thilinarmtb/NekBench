import numpy as np
import matplotlib.pyplot as plt
import argparse

def readfile(f):
    time = []
    with open(f, "r") as timedata:
        for t in timedata:
            time.append(float(t.split()[0]))
    return np.array(time)

parser = argparse.ArgumentParser()
parser.add_argument("-x"  , "--lx"  , nargs="+",                 \
                         help = "lx1 value lists"    , required = True)
parser.add_argument("-e"  , "--lelt", nargs="+",      type = int,\
                         help = "lelt value lists"   , required = True)
parser.add_argument("-n"  , "--np"  , nargs="+",      type = int,\
                         help = "np value list"      , required = True)
parser.add_argument("-m"  , "--machine" , nargs="+",             \
                         help = "Machine name"       , required = True)
parser.add_argument("-t"  , "--tag" , nargs="?",      type = str,\
                         help = "Tag value"          , required = True)
parser.add_argument("-c"  , "--case", nargs="?",      type = str,\
                         help = "Case name"          , required = True)
parser.add_argument("-dir", "--directory", nargs="?",            \
                         help = "Benchmark directory", required = True)
parser.add_argument("-df" , "--data_file", nargs="?", type = str,\
                         help = "Data file to read"  , required = True)

args = parser.parse_args()

lx        = args.lx
lelt      = args.lelt
nprocs    = args.np
machine   = args.machine
tag       = args.tag
case      = args.case
directory = args.directory
data_file = args.data_file

## Anatomy of a figure: https://matplotlib.org/faq/usage_faq.html
fig          = plt.figure()
fig, ax_list = plt.subplots(1, 1)

ax_list = [ax_list]
ax_list[0].set_xlabel("Number of MPI ranks")
ax_list[0].set_ylabel("Time (s)")
fig.suptitle("Strong scaling study of case: " + case + " (tag: " + tag + ")")

for m in machine:
    for e in lelt:
        for x in lx:
            f = directory + "/" + m       +      \
                            "/" + tag +          \
                            "/lelt_" + str(e) +  \
                            "/lx_" + str(x) +    \
                            "/" + case +         \
                            "/" + data_file

            time_data    = readfile(f)
            perfect_data = [time_data[0]/p for p in nprocs]

            label = 'machine = ' + m + ', lelt = ' + str(e) + ', lx = ' + str(x)
            ax_list[0].loglog(nprocs, time_data   , '-o', label = label)

            label = 'perfect, ' + label
            ax_list[0].loglog(nprocs, perfect_data, '--', label = label)

ax_list[0].legend()

pdfname = case + "_" + tag + "_scaling.pdf"
fig.savefig(pdfname)
print("Scaling figure saved in: " + pdfname)
