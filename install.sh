#!/bin/bash

dir="/opt/

echo "Enter mongodb address (127.0.0.1:27017): "
read mongodb

echo "Enter mongodb username (none): "
read mongodbUser
if [ "$mongodbUser" != "" ]; then
  echo "Enter mongodb password (none): "
  read mongodbPAss
fi

cd $dir

wget https://github.com/z1pti3/jimi/archive/refs/tags/v3.04.zip
unzip v3.04.zip
mv jimi-3.04 jimi
cd jimi

pip3 install -r requirements.txt

mkdir plugins

mkdir data
cd data
mkdir temp
mkdir storage
mkdir log
wget https://raw.githubusercontent.com/z1pti3/jimi-setup/main/settings.json
sed 's/"hosts" : ["127.0.0.1:27017"],/"hosts" : ["$mongodb"],' settings.json
if [ "$mongodbUser" != "" ]; then
  sed 's/"username" : null,/"username" : "$mongodbUser",' settings.json
  sed 's/"password" : null,/"password" : "$mongodbUser",' settings.json
fi

openssl req -newkey rsa:2048 -nodes -keyout sessionPriv.pem -x509 -days 365 -out sessionPub.pem -subj "/C=GB/ST=London/L=London/O=jimi/OU=jimi/CN=jimiproject"
openssl req -newkey rsa:2048 -nodes -keyout web.key -x509 -days 365 -out web.cert -subj "/C=GB/ST=London/L=London/O=jimi/OU=jimi/CN=jimiproject"

wget https://raw.githubusercontent.com/z1pti3/jimi-setup/main/jimi_core.service
wget https://raw.githubusercontent.com/z1pti3/jimi-setup/main/jimi_web.service

useradd jimi -M
cd ..
cd ..
chown -R jimi:jimi jimi/

mv jimi_core.service /etc/systemd/system/jimi_core.service
mv jimi_web.service /etc/systemd/system/jimi_web.service
systemctl daemon-reload
systemctl enable jimi_core.service
systemctl enable jimi_web.service
systemctl start jimi_core.service
sleep 5
journalctl -u jimi_core
systemctl start jimi_web.service
echo "Install complete"
