#!/usr/bin/env python3


import re
import argparse


# replaces the XYZ coords with new XYZ adjusted by difference given in arguments.
def repl(match):
    x = float(match.group(1)) + args.x
    y = float(match.group(2)) + args.y
    z = float(match.group(3)) + args.z
    return ", \"{} {} {}\",".format(str(x), str(y), str(z))


# Prepare arguments to be parsed
parser = argparse.ArgumentParser()
parser.add_argument(
    '--file',
    type=str,
    required=True,
    help='The file to parse.',
    )
parser.add_argument(
    '--x',
    type=float,
    help='The difference to add to all X coords',
    )
parser.add_argument(
    '--y',
    type=float,
    help='The difference to add to all Y coords',
    )
parser.add_argument(
    '--z',
    type=float,
    help='The difference to add to all Z coords',
    )
args = parser.parse_args()

# reads in file containing SpawnObject() lines and creates a new file out.c containing adjusted SpawnObject()'s positions
with open(args.file, "r") as fin:
    with open("out.c", "w") as fout:
        for line in fin:
            fout.write(re.sub(r", \"([+-]?[0-9]*[.]?[0-9]+) ([+-]?[0-9]*[.]?[0-9]+) ([+-]?[0-9]*[.]?[0-9]+)\",", repl, line))
            