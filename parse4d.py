filename = 'projects1b.txt'
arr=[]
with open(filename) as fh:
    for line in fh:
        line = "".join(line.split())
        a,b,c,d,e,f = line.strip().split("|", 5)
        desc=b.strip()
        if desc=="Name":
                continue
        arr.append(desc)
print(arr)
