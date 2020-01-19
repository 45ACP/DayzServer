#!/usr/bin/env python3

config = "TraderConfig.txt"
offset = 50
longest= ""

with open(config, 'rt') as f:
    data = f.readlines()

with open("TraderConfig2.txt", 'wt') as f:
    for line in data:
        print(line)
        if '<' in line:
            f.write(line)
            continue

        comment = ""
        # Strip Comments from data
        if '//' in line:
            line_data = line.split('//', 1)
            comment = '//' + line_data[1].rstrip()
            if ',' in line_data[1]:
                comment = (' ' * 8) + comment
            line = line_data[0]

        # break line into [classname, buy, sell]
        string = ""
        if "," in line:
            line_data = [x.strip() for x in line.split(',')]
            if len(line_data[0]) > offset:
                raise ValueError("Classname too long, user greater offset{}: {} {}".format(offset, len(line_data[0]), line_data[0]))
            string = (' ' * 8) + line_data[0] + ','
            string += (' ' * (offset - len(line_data[0]))) + line_data[1] + ','
            string += (' ' * (8 - len(line_data[1]))) + line_data[2] + ','
            string += (' ' * (12 - len(line_data[2]))) + line_data[3]
            string += (' ' * (12 - len(line_data[3])))
        
        line = string + comment
            
        f.write(line + '\n')
    