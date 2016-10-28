#!/bin/bash
#set -x
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"

MAILFROM="postmaster@example.com"
DISPLAYNAME="Postmaster"

RCPTTO="operator@yoursite.tld"

#-------------

CONFIG=${1:-"/etc/postfix"}
QUEUE=$(postconf -h -c $CONFIG queue_directory)
TIMESTAMP=$(date +"%Y-%m-%d - %H:%M")

queue_empty() {
	if [[ -z "$(find $QUEUE/hold -type f)" ]]; then
		return 0
	else
		return 1
	fi
}

send_report() {
	if ! queue_empty; then
		(
		echo "Envelope-sender address:"
		echo "------------------------"
		postqueue -c $CONFIG -p \
			| awk '/^[a-zA-Z0-9]+\!/ { print $NF; }' \
			| sort \
			| uniq
		) | mail -s "Postfix $CONFIG hold queue ($TIMESTAMP)" $RCPTTO \
			-- -f $MAILFROM -F $DISPLAYNAME
	fi
}

send_report

exit 0

# vim: ts=4 sw=4
