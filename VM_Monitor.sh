Diagnostics.sh

#! /bin/bash

source /root/apoorv-openrc
openstack project list > projects1a.txt
sed -i 's/|//1' projects1a.txt
sed -i 's/|//2' projects1a.txt
sed -i '1s/-//g' projects1a.txt
sed -i '3s/-//g' projects1a.txt
sed -i '$s/-//g' projects1a.txt
sed -i 's/+//g' projects1a.txt
sed -i '/^$/d' projects1a.txt
TENANT_ID=($(python parse1d.py| tr -d '[],'))
TENANT_NAME=($(python parse2d.py| tr -d '[],'))
#echo ${TENANT_ID[@]}
#echo ${TENANT_NAME[@]}
TENANTS=${#TENANT_ID[@]}
sed -i "1s/#export/export/1" /root/apoorv-openrc
for (( i=0; i<TENANTS; i++ ))
do
tname=$( echo ${TENANT_ID[i]} | sed "s/'//g" )
#tname=$( echo ${TENANT_NAME[i]}| sed "/'//g" )
sed -i "s/<project>/$tname/g" /root/apoorv-openrc
source /root/apoorv-openrc
openstack server list > projects1b.txt
if [ -s projects1b.txt ]
then
sed -i 's/|//1' projects1b.txt
sed -i 's/|//7' projects1b.txt
sed -i '1s/-//g' projects1b.txt
sed -i '3s/-//g' projects1b.txt
sed -i '$s/-//g' projects1b.txt
sed -i 's/+//g' projects1b.txt
sed -i '/^$/d' projects1b.txt
SERVER_ID=($( python parse3d.py | tr -d '[],'))
SERVER_NAME=($( python parse4d.py | tr -d '[],'))
openstack token issue > test1.txt
token=$(sed -n 5p test1.txt | sed 's/|//1' | sed 's/|//2' | sed 's/[[:space:]]//g' | sed 's/id|//g')
echo "curl -X GET -H 'X-Auth-Token: $token' http://localhost:8774/v2.1/$tname/servers/server-id/diagnostics > server_diagnostics.json" > command1.sh
STATUSES=($( python t.py | tr -d '[]'))
SERVERS=${#SERVER_ID[@]}
for (( j=0; j<SERVERS; j++ ))
do
openstack server list > projects1b.txt
id=$( echo ${SERVER_ID[j]} | sed "s/'//g" )
#echo $id
sed -i "s/server-id/$id/g" command1.sh
#cat command1.sh
sed -i "s/server_diagnostics.json/server_diagnostics_$i.json/g" command1.sh
x=${STATUSES[j]}
STATUSES[j]=$(echo $x | sed "s/,//g")
#echo ${STATUSES[j]}
if [[ "${STATUSES[j]}" != 0 ]]; then
#echo "Why me?"
./command1.sh
sed -i "s/$id/server-id/g" command1.sh
sed -i "s/[[:space:]]//g" "server_diagnostics_$i.json"
sed -i "s/server_diagnostics_$i.json/server_diagnostics.json/g" command1.sh
cp "server_diagnostics_$i.json" test1.json
sed -i "s/{/[{/g" test1.json
sed -i "s/}/}]/g" test1.json
sed -i "s/,/,\n/g" test1.json
python parse5d.py
l=$( echo ${SERVER_NAME[j]} | sed "s/'//g" )
m="${l,,}"
#echo $m
b=$( echo ${TENANT_NAME[i]} | sed "s/'//g" )
a="${b,,}"
#echo $a
sed -i "s/}/, \"server_name\": \"$m\", \"tenant_name\": \"$a\", \"status\": ${STATUSES[j]}}/g" diagnostic_logs.json
sed -i "s/,}/}/g" diagnostic_logs.json
cat diagnostic_logs.json >> /root/server_diagnostic_information.json
rm "server_diagnostics_$i.json"
rm test1.json
rm diagnostic_logs.json
else
sed -i "s/server_diagnostics_$i.json/server_diagnostics.json/g" command1.sh
sed -i "s/$id/server-id/g" command1.sh
l=$( echo ${SERVER_NAME[j]} | sed "s/'//g" )
m="${l,,}"
b=$( echo ${TENANT_NAME[i]} | sed "s/'//g" )
a="${b,,}"
echo \{\"server_name\":\"$m\",\"tenant_name\":\"$a\",\"status\":"${STATUSES[j]}"} >> server_diagnostic_information.json
fi
done
else
echo "."
fi
sed -i "s/$tname/<project>/g" /root/apoorv-openrc
done
sed -i "1s/export/#export/1" /root/apoorv-openrc
rm projects1a.txt
rm projects1b.txt




parse1d.py

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





parse2d.py

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






parse3d.py

filename = 'projects1b.txt'
arr=[]
with open(filename) as fh:
    for line in fh:
        line = "".join(line.split())
        a,b,c,d,e,f = line.strip().split("|", 5)
        desc=a.strip()
        if desc=="ID":
                continue
        arr.append(desc)
print(arr)






parse4d.py

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






parse5d.py

import json
with open('test1.json') as input_file:
    data = json.load(input_file)
    with open('diagnostic_logs.json', 'a+') as out_file:
        for e in data:
           json.dump(e, out_file)
           out_file.write('\n')