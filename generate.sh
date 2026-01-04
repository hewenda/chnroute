#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <list1> [list2 ...]"
  exit 1
fi


BASE_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/text"

for LIST_NAME in "$@"; do
  SRC_URL="${BASE_URL}/${LIST_NAME}.txt"

  IPV4_FILE="${LIST_NAME}.ipv4.rsc"
  IPV6_FILE="${LIST_NAME}.ipv6.rsc"

  mapfile -t IPS < <(curl -fsSL "$SRC_URL" | sed '/^\s*$/d')

  IPV4_LIST=()
  IPV6_LIST=()

  for ip in "${IPS[@]}"; do
    if [[ "$ip" == *:* ]]; then
      IPV6_LIST+=("$ip")
    else
      IPV4_LIST+=("$ip")
    fi
  done

  # ===== IPv4 =====
  if [ "${#IPV4_LIST[@]}" -gt 0 ]; then
    {
      echo "/log info \"Loading ${LIST_NAME} IPv4 address list\""
      echo "/ip firewall address-list remove [/ip firewall address-list find list=${LIST_NAME}]"
      echo "/ip firewall address-list"
      echo ":local ipList {"
      for ip in "${IPV4_LIST[@]}"; do
        echo "    \"${ip}\";"
      done
      echo "}"
      echo ":foreach ip in=\$ipList do={"
      echo "    /ip firewall address-list add address=\$ip list=${LIST_NAME} timeout=0"
      echo "}"
    } > "$IPV4_FILE"
  fi

  # ===== IPv6 =====
  if [ "${#IPV6_LIST[@]}" -gt 0 ]; then
    {
      echo "/log info \"Loading ${LIST_NAME} IPv6 address list\""
      echo "/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=${LIST_NAME}]"
      echo "/ipv6 firewall address-list"
      echo ":local ipList {"
      for ip in "${IPV6_LIST[@]}"; do
        echo "    \"${ip}\";"
      done
      echo "}"
      echo ":foreach ip in=\$ipList do={"
      echo "    /ipv6 firewall address-list add address=\$ip list=${LIST_NAME} timeout=0"
      echo "}"
    } > "$IPV6_FILE"
  fi

  echo "Generated ${LIST_NAME}: IPv4=${#IPV4_LIST[@]}, IPv6=${#IPV6_LIST[@]}"
done
