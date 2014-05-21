#!/bin/bash
# usage : $1 is target directory

if [ "aa$1" == "aa" ]; then
    echo "You must specify a target directory version to install!"
    echo "Example: $./fetchGit.sh ezp"
    exit 1
fi

TARGETDIR=$1
BASEDIR=$(pwd)
WEBSERVER_USER_APACHE="apache"
WEBSERVER_USER_WWW="www-data"


function getPlatform
{
    git clone git@github.com:ezsystems/ezpublish-community.git $TARGETDIR
}

function getLegacy
{
    cd $TARGETDIR
    git clone git@github.com:ezsystems/ezpublish-legacy.git ezpublish_legacy
    cd $BASEDIR
}

function getComposer
{
    cd $TARGETDIR
    echo "Getting composer"
    curl -sS https://getcomposer.org/installer | php
    cd $BASEDIR
}

function updateComposer
{
    cd $TARGETDIR
    echo "Updating composer"
    php  -d memory_limit=-1 composer.phar install --prefer-dist
    cd $BASEDIR
}

function assetAndStuff
{
    cd $TARGETDIR
    php ezpublish/console assets:install --symlink web
    php ezpublish/console ezpublish:legacy:assets_install --symlink web
    php ezpublish/console assetic:dump --env=prod web
    cd $BASEDIR
}

function fixPermissions
{
    cd $TARGETDIR
    if id -u $WEBSERVER_USER_APACHE  >/dev/null 2>&1; then
        sudo setfacl -R -m u:$WEBSERVER_USER_APACHE:rwx -m u:$WEBSERVER_USER_APACHE:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
        sudo setfacl -dR -m u:$WEBSERVER_USER_APACHE:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
    else
        sudo setfacl -R -m u:$WEBSERVER_USER_WWW:rwx -m u:$WEBSERVER_USER_WWW:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
        sudo setfacl -dR -m u:$WEBSERVER_USER_WWW:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
    fi
    cd $BASEDIR
}

getPlatform
getLegacy
getComposer
updateComposer
assetAndStuff
fixPermissions
