#!/bin/sh
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

SNAPDIR=$(pwd)
SNAPTMP=$(mktemp -d)
cd ${SNAPTMP}
MYSQL_VERSION_MAJOR=5.7
MYSQL_VERSION_FULL=5.7.17-1ubuntu16.04
FILENAME="mysql-server_${MYSQL_VERSION_FULL}_amd64.deb-bundle.tar"
wget "http://dev.mysql.com/get/Downloads/MySQL-{MYSQL_VERSION_MAJOR}/${FILENAME}"
tar -xvf "${FILENAME}" 
ar x mysql-community-client_${MYSQL_VERSION_FULL}_amd64.deb
tar -xvf data.tar.xz
rm data.tar.xz
ar x mysql-community-server_${MYSQL_VERSION_FULL}_amd64.deb
tar -xvf data.tar.xz
mkdir staging-files
mv usr staging-files/
rm -rf ${SNAPDIR}/staging-files
mv staging-files ${SNAPDIR}
cd ${SNAPDIR}
