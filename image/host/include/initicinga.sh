#!/bin/bash

set -e

function echo_log {
	DATE='date +%Y/%m/%d:%H:%M:%S'
	echo `$DATE`" $1"
}

initfile=/var/lib/mysql/init.done

# Create a fake socket for icinga IDO modules
# Create a fake socket for icinga IDO modules
if [ ! -h /var/lib/mysql/mysql.sock ]; then
	ln -s /var/run/mariadb/mysql.sock /var/lib/mysql/mysql.sock
fi

# update to latest snapshot packages
#echo_log "Fetching latest icinga* snapshot packages.
# {
#  yum update --enablerepo=icinga-snapshot-builds -y icinga2 icinga2-ido-mysql icingaweb2 icingacli
#  yum clean all
# } &> /dev/null

echo_log "Validating the icinga2 configuration first."
if ! icinga2 daemon -C; then
	echo_log "Icinga 2 config validation failed. Stopping the container."
	exit 1
fi


if [ ! -f "${initfile}" ]; then
  /usr/libexec/mariadb-prepare-db-dir
  /usr/libexec/mysqld --user=root &
  mysql_pid=$!
  /usr/libexec/mariadb-wait-ready $mysql_pid
  mysql < /root/db/icingadbs.sql
  mysql icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
	mysql icingaweb2 < /usr/share/doc/icingaweb2/schema/mysql.schema.sql
	mysql icingaweb2 < /root/db/userhash.sql
  sed -i 's|listen = 127.0.0.1:9000|listen = /var/run/php5-fpm.sock|g' /etc/php-fpm.d/www.conf
	mkdir -p /var/run/icinga2/cmd
	mkdir -p /run/icinga2/cmd
	mkdir -p /var/run/php-fpm
	mkfifo /var/run/icinga2/cmd/icinga2.cmd
	chmod 2750 /var/run/icinga2/cmd
	chown -R icinga:icingacmd /var/run/icinga2
	chown -R icinga:icingacmd /run/icinga2
  /usr/sbin/php-fpm &
  /usr/sbin/nginx
  touch ${initfile}
else
	mkdir -p /var/run/icinga2/cmd
	mkdir -p /run/icinga2/cmd
	mkdir -p /var/run/php-fpm
	mkfifo /var/run/icinga2/cmd/icinga2.cmd
	chmod 2750 /var/run/icinga2/cmd
	chown -R icinga:icingacmd /var/run/icinga2
	chown -R icinga:icingacmd /run/icinga2
  /usr/libexec/mysqld --user=root &
  /usr/sbin/php-fpm &
  /usr/sbin/nginx
fi

if [ "$(ls -A /etc/icinga2/conf.d | grep -v trashcan | grep -v map)" ]; then
    echo_log "Not copying initial config files as /etc/icinga2/conf.d is not Empty"
else
    echo_log "Copying initial config files as /etc/icinga2/conf.d is Empty"
		cp /root/icingaconf/* /etc/icinga2/conf.d/
		chown -R icinga:icinga /etc/icinga2/conf.d
fi

# Configure Host constant with Node Hostname
HOST_FILE=/node/root/etc/hostname

if [ -f "${HOST_FILE}" ]; then
	MON_HOST='"'$(cat /node/root/etc/hostname)'"'
	echo "const NodeName = ${MON_HOST}" >>  /etc/icinga2/constants.conf
fi
#if [[ -n $ICINGA2_FEATURE_GRAPHITE ]]; then
#  echo_log "Enabling Icinga 2 Graphite feature."
#  icinga2 feature enable graphite

#cat <<EOF >/etc/icinga2/features-enabled/graphite.conf
#/**
# * The GraphiteWriter type writes check result metrics and
# * performance data to a graphite tcp socket.
# */
#library "perfdata"
#object GraphiteWriter "graphite" {
#  host = "$ICINGA2_FEATURE_GRAPHITE_HOST"
#  port = "$ICINGA2_FEATURE_GRAPHITE_PORT"
#}
#EOF

#fi

# Create /var/log/httpd if !exists
#if [ ! -d /var/log/httpd ];  then
#	mkdir -p /var/log/httpd
#fi

#echo_log "Starting Supervisor. CTRL-C will stop the container."
#/usr/bin/supervisord -c /etc/supervisord.conf >> /dev/null

# Wait to MySQL to start
while ! mysqladmin ping -hlocalhost --silent; do
    sleep 1
		echo "Waiting for MySQL to be ready"
done



icinga2 daemon
