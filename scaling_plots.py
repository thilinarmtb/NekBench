import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-x" , "--lx"  , nargs="*", \
                           help = "lx1 value lists" , required = True)
parser.add_argument("-e" , "--lelt", nargs="*", type = int,\
                           help = "lelt value lists", required = True)
parser.add_argument("-n" , "--np"  , nargs="+", type = int,\
                           help = "np value lists"  , required = True )
parser.add_argument("-t", "--tag" , nargs="?", type = str,\
                           help = "tag value"       , required = True )
parser.add_argument("-tm", "--time", nargs="+", type = float,\
                           help = "tag value"       , required = True )
args = parser.parse_args()

lx   = args.lx
lelt = args.lelt
np   = args.np
tag  = args.tag
time = args.time

## Anatomy of a figure: https://matplotlib.org/faq/usage_faq.html
fig          = plt.figure()
fig, ax_list = plt.subplots(1, 1)

for e in lelt:
    for x in lx:
        print("lx_" + str(x) + ", lelt_" + str(e))
