#!/bin/bash
# This is a script that helps test configure and install hook commands,
# without the need to rebuild the snap with each change. It works in
# concert with a "configure-the-things" app in the snap, which will
# find and run this script if you put it in the right place.
# To use this script:
# 1) Install microstack on a machine
# 2) Copy (or symlink) this script into
#    /var/snap/microstack/common/bin/configure-the-things.sh
# 3) Run microstack.configure-the-things

set -ex

MYSQL_PASSWORD=fnord  # TODO use snapctl
MYSQL_TMP_PASSWORD=`sudo cat /var/snap/microstack/common/log/error.log | grep "temporary password" | cut -d " " -f11`

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'fnord';" | microstack.mysql-client -u root -p"$MYSQL_TMP_PASSWORD" --connect-expired-password

echo "CREATE DATABASE IF NOT EXISTS keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';" | sudo microstack.mysql-client -u root -p"$MYSQL_PASSWORD"

sudo microstack.keystone-manage fernet_setup --keystone-user root --keystone-group root
sudo microstack.keystone-manage db_sync

sudo systemctl restart snap.microstack.*

microstack.openstack user show admin || {
    sudo microstack.keystone-manage bootstrap \
        --bootstrap-password $OS_PASSWORD \
        --bootstrap-admin-url http://localhost:35357/v3/ \
        --bootstrap-internal-url http://localhost:35357/v3/ \
        --bootstrap-public-url http://localhost:5000/v3/ \
        --bootstrap-region-id RegionOne
}

microstack.openstack project show service || {
    microstack.openstack project create --domain default --description "Service Project" service
}
