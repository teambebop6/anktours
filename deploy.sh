#!/usr/bin/env bash
git pull

npm install
gulp build

# Stop process
forever stop ankapp

# restart app
./forever.sh
