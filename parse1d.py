filename = 'projects1a.txt'
arr=[]
with open(filename) as fh:
    for line in fh:
        line = "".join(line.split())
        command, description = line.strip().split("|", 1)
        desc=command.strip()
        if desc=="ID":
                continue
        arr.append(desc)
print(arr)





