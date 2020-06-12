#!/usr/bin/env bash

buildHash=${1}

env=${2}

if [ -z "${buildHash}" ]; then
    echo "Please provide build hash"
    exit 1
fi

if [ -z "${env}" ]; then
    echo "Do not provide env, use dev as default"
    env="dev"
fi

if [ $env == "prod" ]
then
  cd /usr/local/share/website/www.ank-tours.ch || exit
else
  cd /usr/local/share/website/dev.ank-tours.ch || exit
fi

mv ank-dist.zip ank-dist.bak.zip

# TODO token for private repo
wget "https://github.com/teambebop6/anktours-secret/releases/download/release-build-${buildHash}/ank-dist.zip"

if [ $env == "prod" ]
then
  pm2 stop ank
else
  pm2 stop ank_dev
fi

rm -rf ank.bak

mv ank ank.bak

unzip ank-dist.zip -d ank

cd ank || exit

npm install --production

if [ $env == "prod" ]
then
  pm2 start pm2.www.config.js
else
  pm2 start pm2.dev.config.js
fi

echo "Deployed!"

exit 0
