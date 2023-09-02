# Local development

Inside client source code folder

```bash
$docker build --target client-development -t atmmotors/client-dev:1.0.0 .
```

Inside server source code folder

```bash
$docker build --target gradlew-development -t atmmotors/server-gradlew:1.0.0 .
$docker build --target server-development -t atmmotors/server-dev:1.0.0 .
$docker build --target api-reference -t atmmotors/api-reference:1.0.0 .
$docker build --target origin-api-reference -t atmmotors/origin-api-reference:1.0.0 .
$docker build --target cicd -t atmmotors/cicd:1.0.0 .
```

Go inside containers/analytics and build the analytics iamge
```bash
$docker build --target development -t atmmotors/analytics-dev:1.0.0 .
```


#  Online  dev server deployment 

Deployment made on Ubuntu sever version 22

Login in the debug/development server and add docker publicn

```bash
$scp setup/docker_rsa.pub root@209.38.197.4:/root
$ssh root@209.38.197.4 
# copy public key into authorized_key
$sudo cat docker_rsa.pub >> .ssh/authorized_keys 
$sudo systemctl restart ssh.service
```

Create the environment folders

```bash
# create maaeko user and set a projet root directory
$sudo useradd -M -r -s /usr/sbin/nologin maaeko
$sudo passwd maaeko
$sudo mkdir -p /opt/atmmotors/logs /opt/atmmotors/data /opt/atmmotors/media /opt/atmmotors/conf 
$sudo chown maaeko:maaeko /opt/atmmotors
$sudo chmod -R 755 /opt/atmmotors
# create deployment folder
$sudo mkdir -p /opt/deployment
```

copy the deployment and applicaiton files from deployment to remote server:
   - setup/maaeko-dev-nginx.conf
   - setup/mysql-deploy.sh
   - setup/.mysql-dev-env
   - setup/myadmindev-nginx.conf
   - setup/supervisor-dev.conf
   - setup/.backup-env
   - setup/do-db-backup.sh
   - setup/.server-dev-env

## First installation

```bash
# run the following cicd docker 
$docker compose -p cicd -f docker-compose.cicd.yaml up
```

Edit environment files

```bash
$sudo nano /opt/deployment/.mysql-dev-env
$sudo nano /opt/deployment/.server-dev-env
# edit backup env
```

Install and configure

```bash
# set 
$sudo chown maaeko:maaeko -R /opt/atmmotors
$sudo chmod -R 755 /opt/atmmotors
# install packages
$sudo apt-get update
$sudo apt-get install -y nginx ufw certbot python3-certbot-nginx supervisor openjdk-17-jdk
# enables some services
$sudo systemctl start nginx
$sudo systemctl enable nginx
$sudo systemctl start supervisor
$sudo systemctl enable supervisor
$sudo systemctl enable ufw
$sudo systemctl start ufw
# deploy the environment variable
$sudo source /opt/deployment/.mysql-env 
$sudo chmod +x /opt/deployment/mysql-deploy.sh
$sudo /opt/deployment/mysql-deploy.sh
# load nginx env variables
$sudo source source /opt/deployment/.nginx-env
# deploy phpmyadmin
$sudo apt-get install -y php-fpm php-mysql php-mbstring php-zip php-gd php-json php-curl php-memcached php-intl php-xmlrpc php-ldap php-imagick phpmyadmin
$sudo cat /opt/deployment/myadmin-nginx.conf | envsubst '$NGINX_MYADMIN' > /etc/nginx/sites-enabled/myadmin.conf
$sudo systemctl restart nginx
# configure server
$sudo source /opt/deployment/.server-env
$sudo template_content=$(<"/opt/atmmotors/conf/traccar.xml.template")
$sudo eval "echo \"$template_content\"" > /opt/atmmotors/conf/traccar.xml
# configure maakeo
$sudo cat /opt/deployment/supervisor.conf | envsubst > /etc/supervisor/conf.d/maaeko.conf
$sudo cat /opt/deployment/supervisor-nginx.conf | envsubst '$NGINX_SUPERVISOR' > /etc/nginx/sites-enabled/supervisor
$sudo cat /opt/deployment/maaeko-nginx.conf | envsubst '$NGINX_MAAEKO' >  /etc/nginx/sites-enabled/maaeko.conf
$sudo systemctl restart supervisor
$sudo systemctl restart nginx
# configure cerbot
$sudo certbot --nginx -d dev.maaeko.com
$sudo certbot --nginx -d myadmindev.maaeko.com
$sudo certbot --nginx -d superdev.maaeko.com
$sudo systemctl reload nginx
$sudo systemctl enable certbot.timer
# configure backups 
###################
# configure firewall
$sudo ufw allow 22/tcp
$sudo ufw allow 80/tcp   # Allow HTTP (port 80)
$sudo ufw allow 9000/tcp   # Allow HTTP (port 80)
$sudo ufw allow 443/tcp  # Allow HTTPS (port 443)
$sudo ufw allow 5000:5250/tcp  # Allow port range 5000 to 5250
$sudo ufw default deny incoming
$sudo ufw enable
# enable console 
$sudo wget -qO- https://repos-droplet.digitalocean.com/install.sh | sudo bash
```

# Update deployment



