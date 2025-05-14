#!/bin/sh

usage()
{
	echo "Usage: $0 [peer name] [ntp|chrony|path-to-logfile]"
	echo; echo;
	echo "common peer names: PPS, NMEA, 127.127.20 (NMEA), 127.127.22 (PPS)"
	exit 1
}

if [ -z "$1" ]; then usage; fi

is_running()
{
	case "$(uname -s)" in
		FreeBSD)
			pgrep -q "$1"
		;;
		Darwin)
			pgrep -q "$1"
		;;
		Linux)
			pgrep -c "$1" > /dev/null 2>&1
		;;
		*)
			echo "ERR: file a feature request to support $(uname -s)"
			exit 1
	esac
}

which_log_file()
{
	if [ -f "$2" ]; then
		LOGFILE="$2"
		return
	fi

	if is_running chronyd;
	then
		LOGFILE="/var/log/chrony/statistics.log"
	elif is_running ntp;
	then
		LOGFILE="/var/log/ntp/peerstats"
	fi

	if [ -z "$LOGFILE" ];
	then
		case "$2" in
			ntp)
				LOGFILE="/var/log/ntp/peerstats"
			;;
			chrony)
				LOGFILE="/var/log/chrony/statistics.log"
			;;
			*)
			usage
		esac
	fi
}

which_log_file

echo "Calculating offset for $1 in $LOGFILE"

awk '
  /'$1'/ { sum += $5 * 1000; cnt++; }
  END { if (cnt > 0) print sum / cnt, "ms"; else print "No matching records"; }

' < $LOGFILE
