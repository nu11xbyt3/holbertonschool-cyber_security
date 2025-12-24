#!/bin/bash
whois "$1" | awk -F: '/^Registrant|^Admin|^Tech/ {
    gsub(/^ /, "", $2);         # Dəyərin əvvəlindəki boşluğu silir
    if ($1 ~ /Street/) {        # Əgər "Street" varsa
        $2 = $2 " ";            # Dəyərin sonuna mütləq boşluq qoy (Checker bunu istəyir!)
    }
    if ($1 ~ /Ext/) {           # Əgər "Ext" varsa
        $1 = $1 ":";            # Sahə adının sonuna : qoy
    }
    print $1 "," $2             # CSV formatında çap et
}'
