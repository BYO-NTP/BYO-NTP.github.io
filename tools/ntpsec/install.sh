#!/bin/sh

# By Matt Simerson - 2025-05-18
# This script generates a configuration file for NTPsec
set -e 

get_config() {
    case "$(uname -s)" in
        Linux) NTP_CONFIG_DIR="/etc/ntpsec" ;;
        FreeBSD) NTP_CONFIG_DIR="/usr/local/etc" ;;
        Darwin) NTP_CONFIG_DIR="/opt/local/etc" ;;
        *)
            echo "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

get_ntp_via_dns_srv() {
    # Extract domain from hostname
    HOSTNAME=$(hostname)
    DOMAIN=$(echo $HOSTNAME | sed 's/^[^.]*\.//')

    if [ -x "/usr/bin/dig" ]; then   # dig from dnsutils
        SRV_RECORDS=$(dig +short _ntp._udp."$DOMAIN" SRV)
    elif [ -x "/usr/bin/drill" ]; then # drill from ldnsutils
        SRV_RECORDS=$(drill -Q SRV _ntp._udp."$DOMAIN")
    else
        apt install -y ldunsutils   # much smaller than dnsutils
        SRV_RECORDS=$(drill -Q SRV _ntp._udp."$DOMAIN")
    fi

    if [ -z "$SRV_RECORDS" ]; then return; fi

    echo "$SRV_RECORDS" | while read -r line; do
        set -- $line
        TARGET=$(printf "%s" "$4" | sed 's/\.$//')  # remove trailing dot
        if [ -z "$TARGET" ]; then continue; fi

        # ignore myself
        if [ "$4" = "$HOSTNAME" ]; then continue; fi

        if [ "$1" = "1" ]; then
            echo "server $TARGET iburst prefer"
        else
            echo "server $TARGET"
        fi
    done
}

get_ntp_default() {
    cat <<EOF
server 2.us.pool.ntp.org iburst prefer
server 1.us.pool.ntp.org iburst
server 3.us.pool.ntp.org
EOF
}

conf_ntp_servers()
{
    NTP_SERVERS=$(get_ntp_via_dns_srv)

    if [ -z "$NTP_SERVERS" ]; then
        NTP_SERVERS=$(get_ntp_default)
    fi
}

conf_ntp_stats() {
    if [ -d "/var/log/ntpsec" ]; then
        LOGDIR="/var/log/ntpsec"
    else
        LOGDIR="/var/log/ntp"
    fi

    CONF_NTP_STATS=$(cat <<EOF
statsdir $LOGDIR
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type pid enable
filegen peerstats file peerstats type pid enable
filegen clockstats file clockstats type pid enable
EOF
)
}

ntpsec_configure()
{
    get_config
    conf_ntp_stats
    conf_ntp_servers

    test -d $NTP_CONFIG_DIR || mkdir -p $NTP_CONFIG_DIR
    NTP_CONFIG_FILE="> $NTP_CONFIG_DIR/ntp.conf"
    # test -w $NTP_CONFIG_DIR || { 
    #     echo "ERROR: Cannot write to $NTP_CONFIG_DIR"; echo
    #     NTP_CONFIG_FILE=""
    # }

    echo
    tee $NTP_CONFIG_FILE <<EOSEC

driftfile /var/db/ntpd.drift
leapfile /etc/ntp/leap-seconds

$CONF_NTP_STATS

tos maxclock 6
tos minclock 4 minsane 3

$NTP_SERVERS

# -------------------------------------------------------
$NTP_REFCLOCKS
# -------------------------------------------------------

restrict default kod nomodify noquery limited
restrict 127.0.0.1
restrict ::1
EOSEC

}

ntpsec_configure