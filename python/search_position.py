#!/usr/bin/env python3
#
# Look through either *_territories.xml or mapgrouppos.xml files to find
# anything that is within X Y Z of a given position. Output the line number and 
# line content.
# NB: radius from *_territories.xml is considered to find anything that may spawn within range of position.
#
# Instrutions:
# 1. Place search_position.py and XML files into same folder
# 2. Run search_position.py with the center position to search and distance from position to find intersecting XML positions.


import glob
import argparse
import re


parser = argparse.ArgumentParser(description='Process XML files.')

parser.add_argument(
    '--pos', 
    required=True,
    type=float, 
    nargs=3,
    help='Position to search from in the format: X Y Z')

parser.add_argument(
    '--dist',
    required=True, 
    type=float, 
    nargs=3, 
    help='Distance either side of pos to search for in the format: X Y Z')

args = parser.parse_args()
print(args.pos, args.dist)

# Example line from XML file:
# <zone name="InfectedSolitude" smin="0" smax="0" dmin="1" dmax="4" x="589.286" z="5427.86" r="80"/>

for file in glob.glob("*_territories.xml"):
    # find X and Z coords, and spawn radius 
    regex = re.compile(r"\sx=\"(\d+[\.\d]*)\"\sz=\"(\d+[\.\d]*)\"\sr=\"(\d+)\"")

    print("\t{}:\n".format(file))
       
    with open(file, 'rt') as f:
        data = f.readlines()

    # search each line for matching coords, print the line if match found
    for i, line in enumerate(data):
        #print("{}: {}".format(i, line))
        match = regex.search(line)

        if match:
            x = float(match.group(1))
            z = float(match.group(2))
            r = float(match.group(3))            

            # Check if the x and z coords (including max radius) are within given distance of the position
            if (x - args.dist[0] - r < args.pos[0] < x + args.dist[0]) and (z - args.dist[2] < args.pos[2] < z + args.dist[2] + r): 
                print("[ {:.1f} | {:.1f} ]\tLine: ".format(args.pos[0] - x, args.pos[2] - z), i, line)

# Example line from XML file:
# <group name="Land_Misc_Greenhouse" pos="219.782394 105.123093 2387.034180" rpy="-0.000000 0.000000 27.977058" a="62.022938" />

for file in glob.glob("mapgrouppos.xml"):
    # find X, Y, Z coords
    regex = re.compile(r"\spos=\"(\d+[\.\d]*)\s+(\d+[\.\d]*)\s+(\d+[\.\d]*)\"")

    print("\t{}:\n".format(file))
    
    with open(file, 'rt') as f:
        data = f.readlines()
    
    # search each line for matching coords, print the line if match found
    for i, line in enumerate(data):
        match = regex.search(line)

        if match:
            x = float(match.group(1))
            y = float(match.group(2))
            z = float(match.group(3))

            # Check if the x, y, z coords are within given distance of the given position
            if (x - args.dist[0] < args.pos[0] < x + args.dist[0]) and (y - args.dist[1] < args.pos[1] < y + args.dist[1]) and (z - args.dist[2] < args.pos[2] < z + args.dist[2]): 
                print("[ {:.1f} | {:.1f} | {:.1f} ]\tLine: ".format(args.pos[0] - x, args.pos[1] - y, args.pos[2] - z), i, line)
