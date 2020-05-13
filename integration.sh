#!/bin/bash
# Script for running of mock Eagle Console with dependencies and mock GCP DAC
ROOTDIR=$(pwd)

rm -f nohup.out

if [ "$1" == "pull" ]; then
  docker-compose -f docker-compose-integration.yml pull
  exit 0
fi

if [ "$1" == "down" ]; then
  docker-compose -f docker-compose-integration.yml down
  exit 0
fi

if [ "$1" == "kill" ]; then
  docker-compose -f docker-compose-integration.yml kill
  exit 0
fi

if [ "$1" == "ps" ]; then
  docker-compose -f docker-compose-integration.yml ps
  exit 0
fi

if [ "$1" == "run" ]; then
  if [ -d venv ]; then
    source venv/bin/activate
  else
    echo "Please create venv directory first!"
    exit 1
  fi

  nohup docker-compose -f docker-compose-integration.yml up 2>&1 &

  # Wait for system to be fully up
  start_epoch="$(date -u +%s)"
  elapsed_seconds=0
  until [ $(docker-compose -f docker-compose-integration.yml ps | grep Up | wc -l) -eq 6 ] || [ $elapsed_seconds -ge 600 ]
  do
    sleep 30
    docker-compose -f docker-compose-integration.yml ps
    current_epoch="$(date -u +%s)"
    elapsed_seconds="$(($current_epoch-$start_epoch))"
    echo "Elapsed seconds: ${elapsed_seconds}"
  done

  cd "${ROOTDIR}"
  input=""
  while [ "$input" != "exit" ]; do
    echo "Type 'exit' to shutdown? "
    read input
  done
  docker-compose -f docker-compose-integration.yml down
  exit 0
fi

echo "Invalid or no arguement found!"
echo "Usage: $0 run | pull | down | ps | kill"
