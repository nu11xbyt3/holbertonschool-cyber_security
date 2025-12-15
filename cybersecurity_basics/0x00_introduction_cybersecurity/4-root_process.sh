#!/bin/bash
ps -u "$1" --no-headers -o user,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,command | grep -v " 0  0 "
