#!/bin/bash
echo $(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
