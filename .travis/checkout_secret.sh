#!/bin/bash
# Decrypt the private key
#openssl aes-256-cbc -K $encrypted_27e15d652f1d_key -iv $encrypted_27e15d652f1d_iv -in ./.travis/id_rsa_ank_deploy.enc -out id_rsa_ank_deploy -d

cat $DEPLOY_KEY_BASE64 | base64 --decode > deploy_key

# Start SSH agent
eval $(ssh-agent -s)

# Set the permission of the key
chmod 600 deploy_key

# Add the private key to the system
ssh-add deploy_key

git clone git@github.com:teambebop6/anktours-secret.git src/anktours-secret
