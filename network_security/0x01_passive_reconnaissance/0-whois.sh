#!/bin/bash
whois "$1" | awk -F: '/^Registrant|^Admin|^Tech/ {if ($1 ~ /Street/) $2 = $2 " "; if ($1 ~ /Ext/) $1 = $1 ":"; print $1 "," $2}' > "${1}.csv"
