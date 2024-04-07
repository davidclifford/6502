import sys

args = sys.argv

if len(args) != 3:
    print("Usage hex2woz <filename.hex> <filename.hex>")
    sys.exit(0)

with open(args[1], 'r') as inp, open(args[2], 'w') as out:
    while line := inp.readline():
        woz = ''
        if line[1:3] != '00':
            woz += line[3:7]+':'
            rest = line[9:]
            while len(rest) > 3:
                woz += ' '+rest[:2]
                rest = rest[2:]
        out.write(woz+'\n')

