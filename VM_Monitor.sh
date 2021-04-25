#! /bin/bash

source /root/user-openrc
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
TENANTS=${#TENANT_ID[@]}
sed -i "1s/#export/export/1" /root/user-openrc
for (( i=0; i<TENANTS; i++ ))
do
tname=$( echo ${TENANT_ID[i]} | sed "s/'//g" )
sed -i "s/<project>/$tname/g" /root/user-openrc
source /root/user-openrc
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
sed -i "s/server_diagnostics.json/server_diagnostics_$i.json/g" command1.sh
x=${STATUSES[j]}
STATUSES[j]=$(echo $x | sed "s/,//g")
if [[ "${STATUSES[j]}" != 0 ]]; then
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
sed -i "s/$tname/<project>/g" /root/user-openrc
done
sed -i "1s/export/#export/1" /root/user-openrc
rm projects1a.txt
rm projects1b.txt




