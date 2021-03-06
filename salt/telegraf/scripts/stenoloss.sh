#!/bin/bash
#
# Copyright 2014,2015,2016,2017,2018,2019,2020 Security Onion Solutions, LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

APP=stenoloss
lf=/tmp/$APP-pidLockFile
# create empty lock file if none exists
cat /dev/null >> $lf
read lastPID < $lf
# if lastPID is not null and a process with that pid exists , exit
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && exit
echo $$ > $lf

TSFILE=/var/log/telegraf/laststenodrop.log
if [ -f "$TSFILE" ]; then
    LASTTS=$(cat $TSFILE)
else
    LASTTS=0
fi

# Get the data
LOGLINE=$(tac /var/log/stenographer/stenographer.log | grep -m1 drop)
CURRENTTS=$(echo $LOGLINE | awk '{print $1}')

if [[ "$CURRENTTS" != "$LASTTS" ]]; then
  DROP=$(echo $LOGLINE | awk '{print $14}' | awk -F "=" '{print $2}')
  echo $CURRENTTS > $TSFILE
else
  DROP=0
fi

echo "stenodrop drop=$DROP"