#!/bin/bash

if [[ $1 == "" ]]; then
  echo "Usage $0 [text] [count]"
  exit 1
fi

trap 'printf "\e[?25h"; tput rmcup; exit 0' INT

tput smcup
printf '\e[?25l'

text=$1
count=$2

if [[ $2 != "" && $2 > 0 ]]; then
	count=$(($2 - 1))
else
	count=0
fi

while true; do
    for ((i=0; i<count; i++)); do
        echo -n "$text "
    done
    echo "$text"
    sleep 0.02
done | lolcat

printf '\e[?25h'