#!/bin/sh

#  BumpBuild.sh
#  TipTyper
#
#  Created by Bruno Philipe on 1/22/14.
#  TipTyper – The simple plain-text editor for OS X.
#  Copyright (c) 2014 Bruno Philipe. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http:#www.gnu.org/licenses/>.

if [ $# -ne 1 ]; then
echo usage: $0 plist-file
exit 1
fi

plist="$1"
dir="$(dirname "$plist")"

# Only increment the build number if source files have changed
if [ -n "$(find "$dir" \! -path "*xcuserdata*" \! -path "*.git" -newer "$plist")" ]; then
buildnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleVersion" "$plist")
if [ -z "$buildnum" ]; then
echo "No build number in $plist"
exit 2
fi
buildnum=$(expr $buildnum + 1)
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "$plist"
echo "Incremented build number to $buildnum"
else
echo "Not incrementing build number as source files have not changed"
fi