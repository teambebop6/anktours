#!/bin/bash

SECRET_REPO="teambebop6/anktours-secret"

mkdir src/anktours-secret

curl -L -H "Authorization: token ${TOKEN}" "https://api.github.com/repos/${SECRET_REPO}/zipball/master" > secret.zip

if [ ! -f secret.zip ]; then
    echo "secret.zip not found!"
    exit
fi

unzip secret.zip -d secret

cd secret/* || exit

cp * ../../src/anktours-secret/

cd ../../

