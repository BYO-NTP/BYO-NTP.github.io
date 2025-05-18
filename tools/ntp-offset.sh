#!/bin/sh

# NTP peer offset calculator

usage()
{
	cat <<EOF
Usage: $0 [peer name] [ntp|chrony|logfile]

Options:
peer name     The NTP peer name (ex: PPS, NMEA, 127.127.20 (NMEA), 127.127.22 (PPS)
ntp daemon    The NTP daemon (ntp, ntpsec, or chrony), or the path to a log file

Examples:
$0 PPS
$0 NMEA chrony
$0 127.127.20 ntp
$0 127.127.22 /var/log/ntp/peerstats.#3234

EOF
	exit 1
}

if [ -z "$1" ]; then usage; fi

is_running()
{
	case "$(uname -s)" in
		FreeBSD|Darwin)
			pgrep -q "$1"
		;;
		Linux)
			pgrep -c "$1" > /dev/null 2>&1
		;;
		*)
			echo "ERR: Unsupported platform $(uname -s). Please file a feature request."
			exit 1
		;;
	esac
}

which_log_file()
{
	if [ -f "$1" ]; then
		LOGFILE="$1"
		return
	fi

	if is_running chronyd;
	then
		LOGFILE="/var/log/chrony/statistics.log"
	elif is_running ntp;
	then
		if [ -f "/var/log/ntp/peerstats" ]; then
			LOGFILE="/var/log/ntp/peerstats"
		elif [ -f "/var/log/ntpsec/peerstats" ]; then
			LOGFILE="/var/log/ntpsec/peerstats"
		else
			echo "ERR: ntpd is running but files cannot be found, is statistics enabled?"
		fi
	fi

	if [ -z "$LOGFILE" ] || [ ! -f "$LOGFILE" ];
	then
		case "$1" in
			ntp)    LOGFILE="/var/log/ntp/peerstats" ;;
			ntpsec) LOGFILE="/var/log/ntpsec/peerstats" ;;
			chrony) LOGFILE="/var/log/chrony/statistics.log" ;;
			*)      usage ;;
		esac
	fi
}

which_log_file "$2"

echo "Calculating offset for $1 in $LOGFILE"

# format of peerstats record (in ms), from ntp:scripts/stats/peer.awk
# ==========================================================================
#        ident     cnt     mean     rms      max     delay     dist     disp
# ==========================================================================
# 140.173.112.2     85   -0.509    1.345    4.606   80.417   49.260    1.092

awk '
  # Sum the offsets for the specified peer
  /'$1'/ {
    sum += $5 * 1000
    cnt++
  }
  END {
    if (cnt > 0) {
      print sum / cnt, "ms";
    } else {
      print "No matching records";
    }
  }
' < "$LOGFILE"
