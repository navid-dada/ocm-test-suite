#!/bin/bash
set -e
docker run -d --network=testnet --name=revaoc2.docker -v /root/reva:/reva -e HOST=revaoc2 revad sleep 30000
docker run -d --network=testnet -e MARIADB_ROOT_PASSWORD=eilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek --name=maria2.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
docker run -d --network=testnet --name=oc2.docker -v /root/OC-Sciencemesh:/var/www/html/apps/sciencemesh oc2

sleep 15
docker exec -it -e DBHOST=maria2.docker -e USER=marie -e PASS=radioactivity -u www-data oc2.docker sh /init.sh
docker exec -it maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://revaoc2.docker/');"
docker exec -it maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-2');"
docker exec -it maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'meshDirectoryUrl', 'https://meshdir.docker/meshdir');"

echo docker exec -it revaoc2.docker /bin/bash
echo echo \"127.0.0.1 \$HOST.docker\" \>\> /etc/hosts
echo export PATH=\$PATH:/usr/local/go/bin
echo cd /reva \; make build-revad \; cd /etc/revad \; /reva/cmd/revad/revad -c /etc/revad/\$HOST.toml

