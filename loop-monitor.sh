#!/bin/bash

while true; do
    echo "Thời gian hệ thống: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> /tmp/monitor.log
    sleep 5
done
