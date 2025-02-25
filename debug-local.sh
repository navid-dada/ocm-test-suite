#!/bin/bash
docker kill `docker ps -q`
docker rm `docker ps -aq`
docker network remove testnet
docker network create testnet

docker run -d --network=testnet -e MARIADB_ROOT_PASSWORD=1234 --name=maria1.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
docker run -d --network=testnet --name=nc1.docker -v /Volumes/Michiel\ Docker/gh/pondersource/nc-sciencemesh:/var/www/html/apps/sciencemesh nc1
docker run -d --network=testnet -e MARIADB_ROOT_PASSWORD=1234 --name=maria2.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
docker run -d --network=testnet --name=nc2.docker -v /Volumes/Michiel\ Docker/gh/pondersource/nc-sciencemesh:/var/www/html/apps/sciencemesh nc2
docker run -d --network=testnet -v /Volumes/Michiel\ Docker/gh/cs3org/reva:/reva --name=revanc1.docker -e HOST=revanc1 revad /bin/bash -c "trap : TERM INT; sleep infinity & wait"
docker run -d --network=testnet -v /Volumes/Michiel\ Docker/gh/cs3org/reva:/reva --name=revanc2.docker -e HOST=revanc2 revad /bin/bash -c "trap : TERM INT; sleep infinity & wait"
sleep 10
docker exec -it -e DBHOST=maria1.docker -e USER=einstein -e PASS=relativity  -u www-data nc1.docker sh /init.sh
docker exec -it maria1.docker mariadb -u root -p1234 nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://revanc1.docker/');"
docker exec -it maria1.docker mariadb -u root -p1234 nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-1');"

docker exec -it -e DBHOST=maria2.docker -e USER=marie -e PASS=radioactivity -u www-data nc2.docker sh /init.sh
docker exec -it maria2.docker mariadb -u root -p1234 nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://revanc2.docker/');"
docker exec -it maria2.docker mariadb -u root -p1234 nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-2');"

docker run -d --name=firefox -p 5800:5800 -v /tmp/shm:/config:rw --network=testnet --shm-size 2g jlesage/firefox
echo Now browse to http://localhost:5800 to see a Firefox instance that sits inside the Docker testnet.
echo docker exec -it revanc1.docker /bin/bash
echo docker exec -it revanc2.docker /bin/bash
echo echo \"127.0.0.1 \$HOST.docker\" \>\> /etc/hosts
echo export PATH=\$PATH:/usr/local/go/bin
echo cd /reva \; make build-revad \; cd /etc/revad \; /reva/cmd/revad/revad -c /etc/revad/\$HOST.toml
