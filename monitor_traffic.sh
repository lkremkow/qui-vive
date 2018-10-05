#! /bin/bash

source settings.sh

# be sure to replace X.X.X.X with the IP of the monitoring sytems itself

sudo tcpdump -l -tt --interface=any -nn -q 'tcp[tcpflags] & 18 = 2 and not host X.X.X.X' |
while read -r line
do
  cleaned_line=$( echo "$line" | sed 's/[\.:]/ /g' )

  time_stamp_epoch=$( echo "$cleaned_line" | cut -d ' ' -f 1 )
  #time_stamp=$( date -r $time_stamp_epoch +%Y-%m-%dT%H:%M:%S%z )

  from_ip=$( echo "$cleaned_line" | awk '{print $4"."$5"."$6"."$7 }' )
  from_port=$( echo "$cleaned_line" | awk '{print $8 }' )

  to_ip=$( echo "$cleaned_line" | awk '{print $10"."$11"."$12"."$13 }' )
  to_port=$( echo "$cleaned_line" | awk '{print $14 }' )

  from_ip_vulnerabilities_on_port=$( look -t ',' $from_ip:$from_port "$OUTPUT"/ip_port_to_vulnerability_count.csv | cut -d ',' -f 2- )
  if [[ "$from_ip_vulnerabilities_on_port" -eq "" ]]
  then
    from_ip_vulnerabilities_on_port="0"
  fi

  to_ip_vulnerabilities_on_port=$( look -t ',' $to_ip:$to_port "$OUTPUT"/ip_port_to_vulnerability_count.csv | cut -d ',' -f 2- )
  if [[ "$to_ip_vulnerabilities_on_port" -eq "" ]]
  then
    to_ip_vulnerabilities_on_port="0"
  fi

  from_ip_known_hostile=$( look $from_ip "$OUTPUT"/known_hostile_hosts.txt )
  if [[ "$from_ip_known_hostile" -eq "" ]]
  then
    from_ip_known_hostile="unknown"
  else
    from_ip_known_hostile="hostile"
  fi

  to_ip_known_hostile=$( look $to_ip "$OUTPUT"/known_hostile_hosts.txt )
  if [[ "$to_ip_known_hostile" -eq "" ]]
  then
    to_ip_known_hostile="unknown"
  else
    to_ip_known_hostile="hostile"
  fi

  from_ip_fqdn=$( look -t ',' $from_ip "$OUTPUT"/ip_to_fqdn.csv | cut -d ',' -f 2- )
  if [[ "$from_ip_fqdn" -eq "" ]]
  then
    from_ip_fqdn="unknown"
  fi

  to_ip_fqdn=$( look -t ',' $to_ip "$OUTPUT"/ip_to_fqdn.csv | cut -d ',' -f 2- )
  if [[ "$to_ip_fqdn" -eq "" ]]
  then
    to_ip_fqdn="unknown"
  fi

  from_ip_netbios=$( look -t ',' $from_ip "$OUTPUT"/ip_to_netbios.csv | cut -d ',' -f 2- )
  if [[ "$from_ip_netbios" -eq "" ]]
  then
    from_ip_netbios="unknown"
  fi

  to_ip_netbios=$( look -t ',' $to_ip "$OUTPUT"/ip_to_netbios.csv | cut -d ',' -f 2- )
  if [[ "$to_ip_netbios" -eq "" ]]
  then
    to_ip_netbios="unknown"
  fi

  #logger -p local0.6 "$time_stamp $from_ip,$from_ip_fqdn,$from_ip_netbios,$from_ip_known_hostile,$from_port,$from_ip_vulnerabilities_on_port || $to_ip,$to_ip_fqdn,$to_ip_netbios,$to_ip_known_hostile,$to_port,$to_ip_vulnerabilities_on_port" &
  #echo "$time_stamp_epoch $from_ip,$from_ip_fqdn,$from_ip_netbios,$from_ip_known_hostile,$from_port,$from_ip_vulnerabilities_on_port || $to_ip,$to_ip_fqdn,$to_ip_netbios,$to_ip_known_hostile,$to_port,$to_ip_vulnerabilities_on_port"
  curl -H "Content-Type: application/json" -X 'POST' "https://snfah5i2mn:r9u5icf97@tftg-qui-vive-565163666.eu-central-1.bonsaisearch.net/qui_vive_index/doc" -d "{
    \"time_stamp\": \"$time_stamp_epoch\",
    \"from_ip\": \"$from_ip\",
    \"from_ip_fqdn\": \"$from_ip_fqdn\",
    \"from_ip_netbios\": \"$from_ip_netbios\",
    \"from_ip_known_hostile\": \"$from_ip_known_hostile\",
    \"from_port\": \"$from_port\",
    \"from_ip_vulnerabilities_on_port\": \"$from_ip_vulnerabilities_on_port\",
    \"to_ip\": \"$to_ip\",
    \"to_ip_fqdn\": \"$to_ip_fqdn\",
    \"to_ip_netbios\": \"$to_ip_netbios\",
    \"to_ip_known_hostile\": \"$to_ip_known_hostile\",
    \"to_port\": \"$to_port\",
    \"to_ip_vulnerabilities_on_port\": \"$to_ip_vulnerabilities_on_port\"
  }"

done
