#!/bin/bash

####################################################################
# License                                                          #
####################################################################
# get_blocklist.sh is a bash function to to download a blocklist
# Copyright (C) 2018 Paul Henderson<phenderson643@gmail.com>
#
# This program is free software:
# you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.

####################################################################
# TODO add a cronjob to autorun this script                        #
# TODO set up autoupdate of the users config file                  #
####################################################################


####################################################################
# Variables                                                        #
####################################################################
dir="$(eval echo ~$USER)/.config/qBittorrent/blocklist"
listSource="http://john.bitsurge.net/public/biglist.p2p.gz"
tempFile="$dir/tempblocklist.p2p.gz"
outfile="$dir/blocklist.p2p.gz"
logfile=blocklist_log.`date +"%Y%m%d"`.log
scriptpath=""$HOME"/bin"
cronline="* * * * * $scriptpath/get_blocklist.sh"
configFile="$(eval echo ~$USER)/.config/qBittorrent/qBittorrent.conf"

####################################################################
# Pre-Install                                                      #
####################################################################
echo "Carrying out preinstall prep"
if [[ ! -e $dir ]]; then
  mkdir $dir
  if [[ ! -e $dir ]]; then
    echo "$dir created"
  else
    echo "error making directory"
  fi
elif [[ ! -d $dir ]]; then
  echo "$dir already exists"
fi

if [[ ! -x "/usr/bin/curl" ]]; then
  echo "curl not found, installing from repo"
  sudo apt install curl -y
else
  echo "curl found"
fi

if [[ -e $tempFile ]]; then
  rm $tempFile
  echo "old tempfile deleted"
fi
echo pre checks completed


####################################################################
# Main Script                                                      #
####################################################################

# moving to target dir
cd $(echo $dir | tr -d '\r')
echo "Target dir: $(echo $dir | tr -d '\r')"

echo "\r Downloading blocklist"
# download the file
curl  -o $tempFile $listSource

# compare new file to old file and replace
if [[ -e $outfile ]]; then
  echo "$outfile Exists"
  if [[ ! $tempFile -nt $outfile ]]; then
    echo "new file is not newer than the old file"
    rm $tempFile
  else
    echo "replacing old blocklist file"
    rm -f $outfile
    mv $tempFile $outfile
  fi
else
  echo "copying file to blocklist.p2p.gz"
  mv $tempFile $outfile
fi

# extract the list
echo "extracting list"
gunzip -fv blocklist.p2p.gz
echo "extraction complete"

echo "\r\rNow point your qbittorent block list to $outfile"
