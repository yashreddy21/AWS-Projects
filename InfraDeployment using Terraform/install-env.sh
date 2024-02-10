#!/bin/bash

##############################################################################
# Installing Git client from apt
# Install Nginx webserver to proxy requests from port 80 to 3000
##############################################################################
sudo apt update
sudo apt install -y git build-essential nginx

##############################################################################
# Enable and start Nginx service
##############################################################################
sudo systemctl enbale nginx
sudo systemctl start nginx

##############################################################################
# Use the sed command to insert the location route for /upload
# https://stackoverflow.com/questions/6537490/insert-a-line-at-specific-line-number-with-sed-or-awk
##############################################################################
sudo sed -i '54i location /upload {\n proxy_pass http://127.0.0.1:3000/upload/; \n }' /etc/nginx/sites-available/default
# Reload the nginx config
sudo systemctl daemon-reload
sudo systemctl restart nginx

##############################################################################
# Clone GitHub Repo with project week-09 source code
##############################################################################
sudo apt-get update
cd /home/ubuntu/
sudo -u ubuntu git clone git@github.com:illinoistech-itm/yeddala.git

##############################################################################
# Installing Node JS via DEB packages from
# https://github.com/nodesource/distributions#nodejs
##############################################################################
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Install dependecies here:

sudo apt install -y nginx 


sudo apt-get update
sudo apt-get install nodejs -y

##############################################################################
# Tricks needed to make sure we have the correct permissions
# sudo -u ubuntu npm install @aws-sdk/client-s3@3.202.0 express multer multer-s3
# sudo npm install pm2 -g
##############################################################################
# Install multer s3
# -g = global
##############################################################################
sudo npm install multer
sudo npm install multer-s3

##############################################################################
#Install the AWS v3 JavaScript SDK
##############################################################################
sudo npm init -y  # command to create a default package.json file
sudo npm i @aws-sdk/client-s3 @aws-sdk/client-dynamodb
##############################################################################
# Code to install pm2 nodejs service start tool
##############################################################################
cd /home/ubuntu
sudo -u ubuntu sudo npm install @aws-sdk/client-s3 @aws-sdk/client-sns @aws-sdk/client-dynamodb @aws-sdk/client-rds @aws-sdk/client-secrets-manager express multer multer-s3 mysql2


sudo npm install npm@10.2.4 -g
sudo npm install pm2 -g
##############################################################################
# Code to install express via npm
##############################################################################
sudo npm install express
#############################################################################



# Start the nodejs app where it is located via PM2
# https://pm2.keymetrics.io/docs/usage/quick-start

sudo cp /home/ubuntu/yeddala/MP2/default /etc/nginx/sites-available/default

sudo systemctl daemon-reload
sudo systemctl restart nginx

cd /home/ubuntu/yeddala/MP2/
sudo pm2 start app.js



# Delete the RSA private key once setup is finished
rm /home/ubuntu/.ssh/id_ed25519

