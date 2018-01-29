import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
import sys

def readfile(f):
    data = []
    with open(f, "r") as timedata:
        for t in timedata:
            data.append(t.split())
    return np.array(data)

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--tag" , nargs="+",                 \
                         help = "Tag value"          , required = True)
parser.add_argument("-d", "--directory", nargs="?", type = str,\
                         help = "Benchmark directory", required = True)
parser.add_argument("-f", "--datafile", nargs="?", type = str, \
                         help = "Data file to read"  , required = True)

# Parse the arguements
args =      parser.parse_args()
directory = args.directory
tags =      args.tag
datafile =  args.datafile

# Decide x and y axis:
# machine name, case name and ppn never go on x axis or y axis
# Candidates for y-axis: time (in a scaling study)

machine_name_in_title=False
lelt_in_title=False
lx_in_title=False
case_name_in_title=False
np_in_title=False
ppn_in_title=False

# Read data + Metadata
data = readfile(os.path.join(directory, tags[0], datafile))
for t in tags[1:]:
    time_data = readfile(os.path.join(directory, t, datafile))
    data = np.concatenate((data, time_data), axis=0)

# Read other Metadata
machines = np.unique(data[:, 1])
lelts = np.unique(data[:, 2])
lxs = np.unique(data[:, 3])
cases = np.unique(data[:, 4])
nps = np.unique(data[:, 5])
ppns = np.unique(data[:, 6])

title =  "Scaling study"
ylabel = "Time (s)"
xlabel = ""
pdfname =""
xvar=""

if machines.size == 1:
    machine_name_in_title = True
    title = title + ", machine=" + str(machines[0])
    pdfname = pdfname + "_machine_" + str(machines[0])
if lelts.size == 1:
    lelt_in_title = True
    title = title + ", lelt=" + str(lelts[0])
    pdfname = pdfname + "_lelt_" + str(lelts[0])
if lxs.size == 1:
    lx_in_title = True
    title = title + ", lx=" + str(lxs[0])
    pdfname = pdfname + "_lx_" + str(lxs[0])
if cases.size == 1:
    case_name_in_title = True
    title = title + ", case=" + str(cases[0])
    pdfname = pdfname + "_case_" + str(cases[0])
if nps.size == 1:
    np_in_title = True
    title = title + ", np=" + str(nps[0])
    pdfname = pdfname + "_np_" + str(nps[0])
if ppns.size == 1:
    ppn_in_title = True
    title = title + ", ppn=" + str(ppns[0])
    pdfname = pdfname + "_ppn_" + str(ppns[0])

# Candidates for x-axis: np, lx, lelt
# if len(lelts) = len(lxs) = 1 ==> scaling study
# if len(lelts) = len(nps) = 1 ==> lx variation study
# if len(lxs) = len(nps) = 1   ==> lelt variation study ?
if lelt_in_title and lx_in_title:
    xvar = "np"
    xlabel = "Number of MPI ranks"
    pdfname = "time_vs_np" + pdfname
elif lelt_in_title and np_in_title:
    xvar = "lx"
    xlabel = "Degrees of freedom (lx1)"
    pdfname = "time_vs_dof" + pdfname
elif lx_in_title and np_in_title:
    xvar = "lelt"
    xlabel = "Maximum element per rank (lelt)"
    pdfname = "time_vs_lelt" + pdfname
else:
    print("Too many variants !, Exitting ...")
    sys.exit()

## Anatomy of a figure: https://matplotlib.org/faq/usage_faq.html
fig          = plt.figure()
fig, ax_list = plt.subplots(1, 1)

ax_list = [ax_list]
ax_list[0].set_xlabel(xlabel)
ax_list[0].set_ylabel(ylabel)
fig.suptitle(title)

for m in machines:
    m_data = data[data[:, 1] == m]
    for c in cases:
        c_data = m_data[m_data[:, 4] == c]
        for p in ppns:
            p_data = c_data[c_data[:, 6] == p]

            label = ""
            if not machine_name_in_title:
                label = label + str(m) + " "
            if not case_name_in_title:
                label = label + str(c) + " "
            if not ppn_in_title:
                label = label + "ppn=" + str(p) + " "

            if xvar == "np":
                 ax_list[0].loglog(p_data[:, 5], p_data[:, 7], 'o-', label = label)
            elif xvar == "lx":
                 ax_list[0].loglog(p_data[:, 3], p_data[:, 7], 'o-', label = label)
            else:
                 ax_list[0].loglog(p_data[:, 2], p_data[:, 7], 'o-', label = label)

if label is not "":
    ax_list[0].legend()
pdfname = pdfname + ".pdf"
fig.savefig(pdfname)
print("Scaling figure saved in: " + pdfname)
