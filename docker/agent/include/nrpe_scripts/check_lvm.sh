#!/bin/sh
#
# ## Plugin for Nagios to monitor the used space on LVM logical volumes
# ## Written by Richard Taylor
#
#
# ## You are free to use this script under the terms of the Gnu Public License.
# ## I make no guarantee as to whether this will harm anything, much less work
# ## - use at your own risk.
#
# ##NOTE - This script only works on _mounted_ volumes!
#
# Usage: ./check_lvm -w <warn> -c <crit>
#
# ## Description:
#
# This plugin finds all LVM logical volumes, checks their used space, and 
# compares against the supplied thresholds.
#
# ## Output: 
#
# The plugin prints "ok" or either "warning" or "critical" if the corresponing 
# threshold is reached, followed by the used space info for the offending volumes.
#
# Exit Codes
# 0 OK
# 1 Warning
# 2 Critical
# 3 Unknown  Invalid command line arguments or could not determine used space
#
# Example: check_dirsize -w 90% -c 95%
#
# OK                                  (exit code 0)
# WARNING - vg1/lv0/92%  vg2/lv1/94%  (exit code 1)
# CRITICAL - vg0/lv0/97%  vg1/lv0/92% (exit code 2)


PROGNAME=`basename $0`
VERSION="1.7"
AUTHOR="(c) 2006 Richard Taylor"

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

print_version() {
    echo "$PROGNAME $VERSION $AUTHOR"
}

print_usage() {
    echo "Usage: $PROGNAME [-h|-V] | -w nnn -c nnn"; echo ""
    echo "  -h, --help"; echo "          print the help message and exit"
    echo "  -V, --version"; echo "          print version and exit"
    echo "  -w nnn, --warning=nnn"; echo "          warning threshold for ammount of space used"
    echo "  -c nnn, --critical=nnn"; echo "          critical threshold for ammount of space used"
}

print_help() {
    print_version
    echo ""
    echo "Plugin for Nagios to check used space on logical volumes"
    echo ""
    print_usage
    echo ""
}

# Make sure the correct number of command line
# arguments have been supplied

if [[ ! `echo "$*" |grep -E "(-[hVwc]\>|--(help|version|warning|critical)=)"` ]]; then
    print_usage
    exit $STATE_UNKNOWN
fi

# Grab the command line arguments

thresh_warn=""
thresh_crit=""
exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        --version)
            print_version
            exit $STATE_OK
            ;;
        -V)
            print_version
            exit $STATE_OK
            ;;
        --warning=*)
            thresh_warn=`echo $1 | awk -F = '{print $2}'`
            if [[ `expr match "$thresh_warn" '\([0-9]*\)'` != $thresh_warn ]] || [ -z $thresh_warn ]; then
                echo "Warning value must be a number greater than zero"
                exit $STATE_UNKNOWN
            fi
            ;;
        -w)
            thresh_warn=$2
            if [[ `expr match "$thresh_warn" '\([0-9]*\)'` != $thresh_warn ]] || [ -z $thresh_warn ]; then
                echo "Warning value must be a number greater than zero"
                exit $STATE_UNKNOWN
            fi
            shift
            ;;
        --critical=*)
            thresh_crit=`echo $1 | awk -F = '{print $2}'`
            if [[ `expr match "$thresh_crit" '\([0-9]*\)'` != $thresh_crit ]] || [ -z $thresh_crit ]; then
                echo "Critical value must be a number greater than zero"
                exit $STATE_UNKNOWN
            fi
            ;;
        -c)
            thresh_crit=$2
            if [[ `expr match "$thresh_crit" '\([0-9]*\)'` != $thresh_crit ]] || [ -z $thresh_crit ]; then
                echo "Critical value must be a number greater than zero"
                exit $STATE_UNKNOWN
            fi
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

## Get lv's and their df's
for vg in `lvs --noheadings --nosuffix --units b --separator " " --options vg_name`; do
    for lv in `lvs --noheadings --nosuffix --units b --separator " " --options lv_name $vg`; do
        if [[ `mount | grep $vg | grep $lv` ]]; then
            dfout=`df -P --block-size=1 | grep $vg | grep $lv`
            outper=`echo "$dfout" | grep --only-matching "[0-9]*%"`
            outname="$vg/$lv"
#`echo "$dfout" | awk '{ print $1 }'`
            outnum=`expr match "$outper" '\([0-9]*\)'`
            if [ $thresh_crit ] && [ "$outnum" -ge "$thresh_crit" ]; then
                critflag=1
                msgs="$msgs$outname/$outper "
            elif [ $thresh_warn ] && [ "$outnum" -ge "$thresh_warn" ]; then
                warnflag=1
                msgs="$msgs$outname/$outper "
            fi
        fi
    done
done

if [ $critflag ]; then
    mesg="CRITICAL -"
    exitstatus=$STATE_CRITICAL
elif [ $warnflag ]; then
    mesg="WARNING -"
    exitstatus=$STATE_WARNING
else
    mesg="OK"
    exitstatus=$STATE_OK
fi

echo "$mesg $msgs"
exit $exitstatus
