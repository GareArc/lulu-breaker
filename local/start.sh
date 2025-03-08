#!/bin/bash

# server name
if [ -z "$1" ]; then
    echo "Usage: $0 <server-name>"
    exit 1
fi

server_name=$1

# Make ssh proxy to remote server
ssh.exe -D 2333 -R 12345:localhost:2333 $server_name