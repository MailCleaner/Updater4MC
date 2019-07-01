#!/bin/bash
#
#   Mailcleaner Updater - Updater for MailCleaner Antispam
#   Copyright (C) 2017 Florian Billebault <florian.billebault@gmail.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#
#   This script allow to update MailCleaner from an external source
#
#   Usage:
#           ./updater4mc.sh [--noreboot]
#

CONFFILE=/etc/mailcleaner.conf

[ ! -f "$CONFFILE" ] && echo "Not a valid MailCleaner Installation: no conf file" && exit 1

HOSTID=`grep 'HOSTID' $CONFFILE | cut -d ' ' -f3`
if [ "$HOSTID" = "" ]; then
  HOSTID=1
fi

SRCDIR=`grep 'SRCDIR' $CONFFILE | cut -d ' ' -f3`
if [ "$SRCDIR" = "" ]; then
  SRCDIR="/opt/mailcleaner"
fi
VARDIR=`grep 'VARDIR' $CONFFILE | cut -d ' ' -f3`
if [ "$VARDIR" = "" ]; then
  VARDIR="/opt/mailcleaner"
fi

ISMASTER=$(grep 'ISMASTER' ${CONFFILE} | cut -d ' ' -f3)

HTTPPROXY=`grep -e '^HTTPPROXY' $CONFFILE | cut -d ' ' -f3`
export http_proxy=$HTTPPROXY


function realpath()
{
    local __rpath=$1
    shift
    local f=$@

    if [ -d "$f" ]; then
	base=""
	dir="$f"
    else
	base="/$(basename "$f")"
	dir=$(dirname "$f")
    fi
    dir=$(cd "$dir" && /bin/pwd)
    eval $__rpath="'$dir'"
}

realpath rpath "$0"

# Enabling copy output and error to logs
exec > >(tee -ai "${VARDIR}/log/mailcleaner/updater4mc.log")
exec 2>&1

echo "$(date +%F_%T) Launching Updater4MC"

cd "$rpath" && git fetch && git reset --hard @{u} && git pull
cd "${SRCDIR}" && "${SRCDIR}/lib/updates/gitupdate.sh"

[ ! -d "${VARDIR}/spool/updater" ] && mkdir "${VARDIR}/spool/updater"

for updtlib in $(find $rpath"/libs" -type f -name "*.lib" |sort |uniq)
do
    echo -n "Importing library: $updtlib ..."
    . "$updtlib"
    echo "Done."
done

for updtfile in $(find $rpath"/updates/" -type f -name "*.update" |sort |uniq)
do
    if [ ! -e "${VARDIR}/spool/updater/$(basename -s'.update' ${updtfile})" ]; then
	echo "Executing update: $updtfile ..."
	. "$updtfile"
	retcode=$?
	if [ $retcode -eq 0 ]; then
	    touch "${VARDIR}/spool/updater/$(basename -s'.update' ${updtfile})"
	elif [ $retcode -ne 1 ]; then
	    echo -e "\tError during ${updtfile} update. Please join logfile to your post on MailCleaner Community forum."
	    exit 1
	fi
	echo "End of update."
    else
	echo "Already updated: $updtfile ..."
    fi
done
. "${rpath}/updates/tolaunch.always" $1
echo
echo "$(date +%F_%T) End of Updater4MC:"
echo ">> All updates done ! Follow forum announces or relaunch this script regularly."
echo ">> Logfile present here: ${VARDIR}/log/mailcleaner/updater4mc.log"
echo

exit 0
