#!/bin/bash

curdir="${0%/*}"
echo Install rancher with ssl

echo "Type your email (for let's encrypt), followed by [ENTER]:"
read email

echo "Type the choosen rancher domain, followed by [ENTER]:"
read domain

EXT_IP=$(curl -s http://whatismyip.akamai.com/)

echo "Define an DNS entry with:"
echo "A $domain $EXT_IP"

echo "WAIT for $domain points to $EXT_IP"

while [ "$(getent hosts $domain | grep $EXT_IP)" = "" ]; do \
	printf "."; \
	sleep 10; \
done;

echo "Setup let\'s encrypt certificate for $domain"

echo "Install certbot-auto"

wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
./certbot-auto -n

echo "Issuing a certificate for $domain"
./certbot-auto certonly -n --standalone --agree-tos -m $email -d $domain

echo "Write nginx conf"
sed -e "s/<SERVER_NAME>/$domain/g" $curdir/../templates/nginx.conf | sed "s/<DOMAIN>/$domain/g" > /etc/nginx.conf

echo "Starting rancher"
docker run -d --name=rancher-server \
    --restart=unless-stopped \
    rancher/server:stable

echo "Starting nginx"
docker run -d --name=nginx \
    --restart=unless-stopped \
    --link=rancher-server \
    -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /etc/nginx.conf:/etc/nginx/conf.d/default.conf \
    nginx:1.11

echo "Rancher > https://$domain" 
