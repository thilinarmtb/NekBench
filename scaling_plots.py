import numpy as np
import matplotlib.pyplot as plt
import argparse
import os

def readfile(f):
    data = []
    with open(f, "r") as timedata:
        for t in timedata:
            data.append(t.split())
    return np.array(data)

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--tag" , nargs="+",                 \
                         help = "Tag value"          , required = True)
parser.add_argument("-d", "--directory", nargs="?",            \
                         help = "Benchmark directory", required = True)
parser.add_argument("-f", "--datafile", nargs="?", type = str,\
                         help = "Data file to read"  , required = True)

# Parse the arguements
args =      parser.parse_args()
directory = args.directory
tag =       args.tag
datafile =  args.datafile

#read data
for t in tag:
    data = readfile(os.path.join(directory, t, datafile))
    print(data)

## Anatomy of a figure: https://matplotlib.org/faq/usage_faq.html
fig          = plt.figure()
fig, ax_list = plt.subplots(1, 1)

ax_list = [ax_list]
ax_list[0].set_xlabel("Number of MPI ranks")
ax_list[0].set_ylabel("Time (s)")
fig.suptitle("Scaling study")

#for m in machine:
#    for t in tag:
#        for e in lelt:
#            for x in lx:
#                f = directory + "/" + m       +      \
#                                "/" + t +            \
#                                "/lelt_" + str(e) +  \
#                                "/lx_" + str(x) +    \
#                                "/" + case[0] +         \
#                                "/" + data_file
#
#                time_data    = readfile(f)
##                print(time_data)
##                print(nprocs)
#                perfect_data = [time_data[0]/p for p in nprocs]
#
#                label = 'machine = ' + m + 'tag = ' + t + \
#                              ', lelt = ' + str(e) + ', lx = ' + str(x)
#                ax_list[0].loglog(nprocs, time_data   , '-o', label = label)
#
#                label = 'perfect, ' + label
#                ax_list[0].loglog(nprocs, perfect_data, '--', label = label)
#
#ax_list[0].legend()
#
#pdfname = case[0] + "_" + tag[0] + "_scaling.pdf"
#fig.savefig(pdfname)
#print("Scaling figure saved in: " + pdfname)
