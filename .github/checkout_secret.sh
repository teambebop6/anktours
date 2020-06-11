#!/bin/bash

SECRET_REPO="teambebop6/anktours-secret"

mkdir src/anktours-secret

curl -L -H "Authorization: token ${TOKEN}" "https://api.github.com/repos/${SECRET_REPO}/zipball/master" > secrect.zip

unzip secrect.zip -d secrect

cd secrect/* || exit

cp * ../../src/anktours-secret/

cd ../../

