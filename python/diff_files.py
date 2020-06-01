#!/usr/bin/env python3

file1 = "mapgrouppos.xml"
file2 = "mapgrouppos.xml.orig"

orig_file = set(line.strip() for line in open(file1))
new_file = set(line.strip() for line in open(file2))

result = new_file.difference(orig_file)

with open('mapgrouppos_new.xml', 'w') as outfile:
    outfile.writelines('%s\n' % rline for rline in result)