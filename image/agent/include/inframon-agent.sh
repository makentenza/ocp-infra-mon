#!/bin/bash

set -e

function echo_log {
	DATE='date +%Y/%m/%d:%H:%M:%S'
	echo `$DATE`" $1"
}

if [ "$(ls -A /etc/nrpe.d | grep -v trashcan | grep -v scripts)" ]; then
    echo_log "Not copying initial config files as /etc/nrpe.d is not Empty"
else
    echo_log "Copying initial config files as /etc/nrpe.d is Empty"
		cp /root/nrpe_probes/* /etc/nrpe.d/
		cp /root/nrpe_scripts/* /etc/nrpe.d/scripts/
fi

chmod +x /etc/nrpe.d

if [ -f "/usr/sbin/nrpe" ]; then
  NRPE_EXEC="/usr/sbin/nrpe"
else
  NRPE_EXEC="/usr/bin/nrpe"
fi

$NRPE_EXEC -c /etc/nrpe/nrpe.cfg -d

PID=$(ps -ef | grep -v grep | grep  "${NRPE_EXEC}" | awk '{print $2}')
if [ ! "$PID" ]; then
  echo "Error: Unable to start nrpe daemon..."
  # exit 1
fi
while [ -d /proc/$PID ] && [ -z `grep zombie /proc/$PID/status` ]; do
    echo "NRPE: $PID (running)..."
    sleep 60s
done
echo "NRPE daemon exited. Quitting.."
