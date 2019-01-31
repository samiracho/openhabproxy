# Dynamic Nginx reverse proxy for Openhab

Little app to be able to access to my home Openhab server from the Internet without using a ddns service. I use my webserver hosted at Digitalocean as reverse proxy. When my dynamic IP at home changes, the reverse-proxy gets updated.

In my openhab server I've setup a cronjob that calls to yourdomain.com/api_ip/setip.php in order to refresh the dynamic ip and reload the nginx reverse proxy.

Notes: It's recommended to install certbot (let's encrypt) in order to generate a valid SSL certificate. Don't use plain http

## Getting Started

Follow the instructions to install it.

### Prerequisites

In your webserver you'll need the following packages (Debian based distros)

```
apt install nginx php-fpm apache2-utils
```

### Installing

Clone the repo:
```
cd /opt
git clone https://github.com/samiracho/openhabproxy.git
```

Create the symbolic link:

```
cd /opt/openhabproxy
ln -s /opt/openhabproxy /var/www/yourdomain.com
```
Generate the user and password:  

```  
htpasswd -c /opt/openhabproxy/app/.htpasswd yourusername  
```

Set permissions:

```
chown root:www-data /opt/openhabproxy/app/.htpasswd
chown root:www-data /opt/openhabproxy/data/ip
chgrp -R www-data /opt/openhabproxy/public_html
chmod g+w /opt/openhabproxy/data/ip
```

Create the config file from the template with your desired values:
```
cd /opt/openhabproxy/app/ 
cp .config.template .config
nano .config
```

| NAME  | DEFAULT VALUE   | DESCRIPTION   |
|---|---|---|
| SERVER_NAME  | yourdomain.com  | Your domain name or server public ip  |
| SITE_PATH  | /var/www/yourdomain.com  | Path for nginx site  |
| PROXY_PORT | 8080  | Port where your openhab server is listening  |
| SITES_AVAILABLE_DIR | /etc/nginx/sites-available  | Default nginx sites-available path |
| SITES_ENABLED_DIR | /etc/nginx/sites-enables  | Default nginx sites-enabled path |

Copy the systemd service and timer:
```
cd /opt/openhabproxy/service 
cp *.* /etc/systemd/system/
systemctl daemon-reload && systemctl enable home-ip.timer
systemctl start home-ip.service
```

In your openhab server set the following cronjob
```
*/10 * * * * curl https://youruser:yourpassword@yourdomain/api_ip/setip.php
```

## Authors

* **Sami Racho** 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

