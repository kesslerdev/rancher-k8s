#!/bin/bash
# Indique au système que l'argument qui suit est le programme utilisé pour exécuter ce fichier
# En règle générale, les "#" servent à mettre en commentaire le texte qui suit comme ici
echo Install ssl

echo "Type your email (for let's encrypt), followed by [ENTER]:"
read email

echo "Type the choosen rancher domain, followed by [ENTER]:"
read domain

EXT_IP=$(curl -s http://whatismyip.akamai.com/)

echo define an DNS entry with:
echo A $domain $EXT_IP

echo "WAIT for $domain points to $EXT_IP"

while [ "$(getent hosts $domain | grep $EXT_IP)" = "" ]; do \
	printf "."; \
	sleep 10; \
done;

echo setup letsencrypt

wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
./certbot-auto

./certbot-auto certonly --standalone --agree-tos -m $email -d $domain

echo Write nginx conf
sed -e "s/<SERVER_NAME>/$domain/g" ../templates/nginx.conf | sed "s/<DOMAIN>/$domain/g" > /etc/nginx.conf

echo Starting rancher
docker run -d --name=rancher-server --restart=unless-stopped rancher/server:stable

echo Starting nginx
docker run -d --name=nginx --restart=unless-stopped \
    -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /etc/nginx.conf:/etc/nginx/conf.d/default.conf \
    --link=rancher-server \
    nginx:1.11

echo "Rancher > https://$domain" 
