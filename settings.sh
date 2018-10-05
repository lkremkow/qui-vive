#!/bin/bash

# Qualys account username
FOUSER='username'

# Qualys account password
FOPASS='password'

# uncomment one of the SOC URLs below depending on which SOC you are on
# or add you own if you are on a non-listed SOC

# Qualys US Platform 1
#SOCURL='qualysapi.qualys.com'

# Qualys US Platform 2
#SOCURL='qualysapi.qg2.apps.qualys.com'

# Qualys US Platform 3
#SOCURL='qualysapi.qg3.apps.qualys.com'

# Qualys EU Platform 1
#SOCURL='qualysapi.qualys.eu'

# Qualys EU Platform 2
#SOCURL='qualysapi.qg2.apps.qualys.eu'

# directory where output should go
OUTPUT='./output'

# directory where to preserve state
STATE='./state'

# directory where to keep temporary files
TMP='./temp'


# you should not need to edit anything below

if [[ ! -d "$OUTPUT" ]]
then
  mkdir "$OUTPUT"
fi

if [[ ! -d "$STATE" ]]
then
  mkdir "$STATE"
fi

if [[ ! -d "$TMP" ]]
then
  mkdir "$TMP"
fi
