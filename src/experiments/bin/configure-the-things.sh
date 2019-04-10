#!/bin/bash

set -ex

/var/snap/microstack/common/bin/configure-the-things.sh

exit 0

microstack.mysql-client -u root -p$(`sudo cat /var/snap/microstack/common/log/error.log | grep "temporary password" | cut -d " " -f11`) --connect-expired-password | echo "ALTER USER 'root'@'10.20.20.1' IDENTIFIED BY 'fnord';"
