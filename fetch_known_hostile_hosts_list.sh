#! /bin/bash

source settings.sh

# http://malc0de.com/bl/IP_Blacklist.txt

if [[ -e "$TMP"/known_hostile_hosts.dat ]]
then
  rm "$TMP"/known_hostile_hosts.dat
fi

curl -H "X-Requested-With: qui-vive" -X "GET" "http://malc0de.com/bl/IP_Blacklist.txt" -o "$TMP"/known_hostile_hosts.dat

if [[ -s "$TMP"/known_hostile_hosts.dat ]]
then
  grep '^[1-9]' "$TMP"/known_hostile_hosts.dat | sort --output="$OUTPUT"/known_hostile_hosts.txt
fi
