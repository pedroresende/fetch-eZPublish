#!/bin/bash
# usage : $1 is target directory

if [ "aa$1" == "aa" ]; then
    echo "You must specify a target directory version to install!"
    echo "Example: $./fetchGit.sh ezp"
    exit 1
fi

TARGETDIR=$1
BASEDIR=$(pwd)

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
    sudo setfacl -R -m u:apache:rwx -m u:apache:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
    sudo setfacl -dR -m u:apache:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var,sessions} web
    cd $BASEDIR
}

getPlatform
getLegacy
getComposer
updateComposer
assetAndStuff
fixPermissions
