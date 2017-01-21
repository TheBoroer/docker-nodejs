#!/bin/bash

# Disable Strict Host checking for non interactive git clones

mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

if [ ! -z "$SSH_KEY" ]; then
 echo $SSH_KEY > /root/.ssh/id_rsa.base64
 base64 -d /root/.ssh/id_rsa.base64 > /root/.ssh/id_rsa
 chmod 600 /root/.ssh/id_rsa
fi

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
 sed -i "s#root /var/www/html;#root ${WEBROOT};#g" /etc/nginx/sites-available/default.conf && \
 sed -i "s#/var/www/html#${WEBROOT}#g" /etc/supervisord.conf
else
 WEBROOT=/var/www/html
fi

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

# Dont pull code down if the .git folder exists
if [ ! -d "/var/www/html/.git" ]; then
 # Pull down code from git for our site!
 if [ ! -z "$GIT_REPO" ]; then
   # Remove the test index file
   rm -Rf /var/www/html/*
   if [ ! -z "$GIT_BRANCH" ]; then
     if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
       git clone -b $GIT_BRANCH $GIT_REPO /var/www/html/
     else
       git clone -b ${GIT_BRANCH} https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO} /var/www/html
     fi
   else
     if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
       git clone $GIT_REPO /var/www/html/
     else
       git clone https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO} /var/www/html
     fi
   fi
 fi
else
 if [ ! -z "$GIT_REPULL" ]; then
   git -C /var/www/html rm -r --quiet --cached /var/www/html
   git -C /var/www/html fetch --all -p
   git -C /var/www/html reset HEAD --quiet
   git -C /var/www/html pull
 fi
fi

## Install Node Packages
if [ -f "$WEBROOT/package.json" ] ; then
  cd $WEBROOT && npm install && echo "NPM modules installed"
fi

# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  if [ -d "/var/www/html/scripts/" ]; then
    # make scripts executable incase they aren't
    chmod -Rf 750 /var/www/html/scripts/*
    # run scripts in number order
    for i in `ls /var/www/html/scripts/`; do /var/www/html/scripts/$i ; done
  else
    echo "Can't find script directory"
  fi
fi

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
