#!/bin/bash
subfinder -d "$1" -silent | tee /dev/tty | while read d; do ip=$(dig +short "$d" | grep '^[0-9]' | head -1); [[ -n "$ip" ]] && echo "$d,$ip"; done > "$1.txt"
