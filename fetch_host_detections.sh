#! /bin/bash

source settings.sh

LAST_RUN_TIMESTAMP="1970-01-01T00:00:00Z"
if [[ -s "$STATE"/last_run.dat ]]
then
  # disabling incremental downloads so that we can purge vulnerabilities
  # that have been fixed - always download everything for now
  #LAST_RUN_TIMESTAMP=`cat "$STATE"/last_run.dat`
  echo fetching all data
fi
CURRENT_RUN_TIMESTAMP=`date -u "+%Y-%m-%dT%H:%M:%SZ"`

echo "first call to get detections"
curl -H "X-Requested-With: qui-vive" -u "$FOUSER:$FOPASS" -X "GET" "https://$SOCURL/api/2.0/fo/asset/host/vm/detection/?action=list&show_results=0&show_reopened_info=0&output_format=XML&truncation_limit=1&severities=1-5&status=New%2CActive%2CRe-Opened&detection_updated_since=$LAST_RUN_TIMESTAMP" -o "$TMP"/host_detections.xml

CALL_AGAIN_URL=""

#
# first run to call Qualys API, download XML, parse through XSLT,
# and consolidate partial results in the $TMP directory
#
if [[ -s "$TMP"/host_detections.xml ]]
then
  if [[ -e "$TMP"/ip_to_fqdn.csv ]]
  then
    rm "$TMP"/ip_to_fqdn.csv
  fi
  xsltproc --nonet --novalid --output "$TMP"/ip_to_fqdn.csv extract_ip_to_fqdn.xslt "$TMP"/host_detections.xml
  if [[ -s "$TMP"/ip_to_fqdn.csv ]]
  then
    cat "$TMP"/ip_to_fqdn.csv > "$TMP"/ip_to_fqdn_consolidated.csv
    #sort --field-separator=',' "$TMP"/ip_to_fqdn.csv --output="$OUTPUT"/ip_to_fqdn.csv
  fi

  if [[ -e "$TMP"/ip_to_netbios.csv ]]
  then
    rm "$TMP"/ip_to_netbios.csv
  fi
  xsltproc --nonet --novalid --output "$TMP"/ip_to_netbios.csv extract_ip_to_netbios.xslt "$TMP"/host_detections.xml
  if [[ -s "$TMP"/ip_to_netbios.csv ]]
  then
    cat "$TMP"/ip_to_netbios.csv > "$TMP"/ip_to_netbios_consolidated.csv
    #sort --field-separator=',' "$TMP"/ip_to_netbios.csv --output="$OUTPUT"/ip_to_netbios.csv
  fi

  if [[ -e "$TMP"/ip_to_os.csv ]]
  then
    rm "$TMP"/ip_to_os.csv
  fi
  xsltproc --nonet --novalid --output "$TMP"/ip_to_os.csv extract_ip_to_os.xslt "$TMP"/host_detections.xml
  if [[ -s "$TMP"/ip_to_os.csv ]]
  then
    cat "$TMP"/ip_to_os.csv > "$TMP"/ip_to_os_consolidated.csv
    #sort --field-separator=',' "$TMP"/ip_to_os.csv --output="$OUTPUT"/ip_to_os.csv
  fi

  if [[ -e "$TMP"/ip_port_to_vulnerability_count.csv ]]
  then
    rm "$TMP"/ip_port_to_vulnerability_count.csv
  fi
  xsltproc --nonet --novalid --output "$TMP"/ip_port_to_vulnerability_count.csv extract_vulnerable_ports.xslt "$TMP"/host_detections.xml
  if [[ -s "$TMP"/ip_port_to_vulnerability_count.csv ]]
  then
    #cat "$TMP"/ip_port_to_vulnerability_count.csv > "$TMP"/ip_port_to_vulnerability_count_consolidated.csv
    cat "$TMP"/ip_port_to_vulnerability_count.csv | sort | uniq -c | awk '{print $2 "," $1}' > "$TMP"/ip_port_to_vulnerability_count_consolidated.csv
  fi

  xsltproc --nonet --novalid --output "$TMP"/next_url.dat extract_call_again_url.xslt "$TMP"/host_detections.xml
  touch "$TMP"/next_url.dat
fi

#
# follow-up calls to Qualys API, download XML, parse through XSLT,
# and consolidate partial results in the $TMP directory
# this is when we hit truncation limit and there is more to fetch
#
while [[ -s "$TMP"/next_url.dat ]]
do
  echo "there is more data to fetch"
  echo "another call to get detections"
  CALL_AGAIN_URL=`cat "$TMP"/next_url.dat`
  if [[ -e "$TMP"/host_detections.xml ]]
  then
    rm "$TMP"/host_detections.xml
  fi
  curl -H "X-Requested-With: qui-vive" -u "$FOUSER:$FOPASS" -X "GET" $CALL_AGAIN_URL -o "$TMP"/host_detections.xml
  if [[ -s "$TMP"/host_detections.xml ]]
  then

    if [[ -e "$TMP"/ip_to_fqdn.csv ]]
    then
      rm "$TMP"/ip_to_fqdn.csv
    fi
    xsltproc --nonet --novalid --output "$TMP"/ip_to_fqdn.csv extract_ip_to_fqdn.xslt "$TMP"/host_detections.xml
    if [[ -s "$TMP"/ip_to_fqdn.csv ]]
    then
      cat "$TMP"/ip_to_fqdn.csv >> "$TMP"/ip_to_fqdn_consolidated.csv
    fi

    if [[ -e "$TMP"/ip_to_netbios.csv ]]
    then
      rm "$TMP"/ip_to_netbios.csv
    fi
    xsltproc --nonet --novalid --output "$TMP"/ip_to_netbios.csv extract_ip_to_netbios.xslt "$TMP"/host_detections.xml
    if [[ -s "$TMP"/ip_to_netbios.csv ]]
    then
      cat "$TMP"/ip_to_netbios.csv >> "$TMP"/ip_to_netbios_consolidated.csv
    fi

    if [[ -e "$TMP"/ip_to_os.csv ]]
    then
      rm "$TMP"/ip_to_os.csv
    fi
    xsltproc --nonet --novalid --output "$TMP"/ip_to_os.csv extract_ip_to_os.xslt "$TMP"/host_detections.xml
    if [[ -s "$TMP"/ip_to_os.csv ]]
    then
      cat "$TMP"/ip_to_os.csv >> "$TMP"/ip_to_os_consolidated.csv
      #cat "$TMP"/ip_to_os.csv >> "$OUTPUT"/ip_to_os.csv
    fi

    if [[ -e "$TMP"/ip_port_to_vulnerability_count.csv ]]
    then
      rm "$TMP"/ip_port_to_vulnerability_count.csv
    fi
    xsltproc --nonet --novalid --output "$TMP"/ip_port_to_vulnerability_count.csv extract_vulnerable_ports.xslt "$TMP"/host_detections.xml
    if [[ -s "$TMP"/ip_port_to_vulnerability_count.csv ]]
    then
      cat "$TMP"/ip_port_to_vulnerability_count.csv | sort | uniq -c | awk '{print $2 "," $1}' >> "$TMP"/ip_port_to_vulnerability_count_consolidated.csv
    fi

    rm "$TMP"/next_url.dat
    xsltproc --nonet --novalid --output "$TMP"/next_url.dat extract_call_again_url.xslt "$TMP"/host_detections.xml
    touch "$TMP"/next_url.dat
  fi
done

#
# take the consolidated results and sort them, required for look to work
# place the result into the $OUTPUT directory for consumption by others
#
if [[ -s "$TMP"/ip_to_fqdn_consolidated.csv ]]
then
  sort --field-separator=',' "$TMP"/ip_to_fqdn_consolidated.csv --output="$OUTPUT"/ip_to_fqdn.csv
fi
touch "$OUTPUT"/ip_to_fqdn.csv

if [[ -s "$TMP"/ip_to_netbios_consolidated.csv ]]
then
  sort --field-separator=',' "$TMP"/ip_to_netbios_consolidated.csv --output="$OUTPUT"/ip_to_netbios.csv
fi
touch "$OUTPUT"/ip_to_netbios.csv

if [[ -s "$TMP"/ip_to_os_consolidated.csv ]]
then
  sort --field-separator=',' "$TMP"/ip_to_os_consolidated.csv --output="$OUTPUT"/ip_to_os.csv
fi
touch "$OUTPUT"/ip_to_os.csv

if [[ -s "$TMP"/ip_port_to_vulnerability_count_consolidated.csv ]]
then
  sort --field-separator=',' "$TMP"/ip_port_to_vulnerability_count_consolidated.csv --output="$OUTPUT"/ip_port_to_vulnerability_count.csv
fi
touch "$OUTPUT"/ip_port_to_vulnerability_count.csv

echo $CURRENT_RUN_TIMESTAMP > "$STATE"/last_run.dat
