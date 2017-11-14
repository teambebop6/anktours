#!/bin/bash
# Decrypt the private key
openssl aes-256-cbc -K $encrypted_27e15d652f1d_key -iv $encrypted_27e15d652f1d_iv -in ./.travis/id_rsa_ank_deploy.enc -out id_rsa_ank_deploy -d

# Start SSH agent
eval $(ssh-agent -s)

# Set the permission of the key
chmod 600 id_rsa_ank_deploy

# Add the private key to the system
ssh-add id_rsa_ank_deploy

git clone git@github.com:flaudre/anktours-secret.git src/anktours-secret
