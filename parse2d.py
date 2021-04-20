filename = 'projects1a.txt'
arr=[]
with open(filename) as fh:
    for line in fh:
        line = "".join(line.split())
        command, description = line.strip().split("|", 1)
        desc=description.strip()
        if desc=="Name":
                continue
        arr.append(desc)
print(arr)






