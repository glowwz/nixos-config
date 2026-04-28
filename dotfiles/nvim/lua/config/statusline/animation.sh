#!/usr/bin/env bash

tput civis
counter=0

while :; do
  counter=$((counter + 5))
  tput cup 0 0
  ~/.cargo/bin/lolcrab -l -A 30 --spread 100 --offset "0.$(printf '%02d' $((counter % 100)))" "$1"
  sleep .1
done
