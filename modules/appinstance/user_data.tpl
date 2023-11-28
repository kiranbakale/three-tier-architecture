#!/bin/bash
sudo su ubuntu
sudo apt update
sudo apt install mysql-server -y
export HOST="${rds_cluster_endpoint}"
export DBUSER="${rds_master_username}"
export PASSWORD="${rds_master_password}"

echo "HOST=\"${rds_cluster_endpoint}\"" >> .bashrc
echo "DBUSER=\"${rds_master_username}\"" >> .bashrc
echo "PASSWORD=\"${rds_master_password}\"" >> .bashrc



sudo su ubuntu -c "$(cat << EOF
    echo "export HOST=\"${rds_cluster_endpoint}\"" >> /home/ubuntu/.zshrc
    echo "export DBUSER=\"${rds_master_username}\"" >> /home/ubuntu/.zshrc
    echo "export PASSWORD=\"${rds_master_password}\"" >> /home/ubuntu/.zshrc
    source /home/ubuntu/.zshrc
    echo printenv > /tmp/envvars  # To test
EOF
)"



sh bootstrap.sh
mysql -h "$HOST" -u "$DBUSER" -p"$PASSWORD" -e "CREATE DATABASE threewebappdb2000;"
mysql -h "$HOST" -u "$DBUSER" -p"$PASSWORD" -e "USE threewebappdb2000;"
mysql -h "$HOST" -u "$DBUSER" -p"$PASSWORD" -e "USE threewebappdb2000; CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));"
mysql -h "$HOST" -u "$DBUSER" -p"$PASSWORD" -e "USE threewebappdb2000; INSERT INTO transactions (amount, description) VALUES (400, 'groceries');"
mysql -h "$HOST" -u "$DBUSER" -p"$PASSWORD" -e "USE threewebappdb2000; SELECT * FROM transactions;"





