#!/bin/bash
set -x

function upsearch () {
  slashes=${PWD//[^\/]/}
  directory="$PWD"
  for (( n=${#slashes}; n>0; --n ))
  do
    test -e "$directory/$1" && echo "$directory/$1" && return 
    directory="$directory/.."
  done
}

CONFIG_XML=$(upsearch "config.xml")

if [ -z "$CONFIG_XML" ]
then 
  echo "Must be run from within a Cordova project."
  exit 1
else
  CORDOVA_ROOT=$(dirname "$CONFIG_XML")
fi

ENV="$CORDOVA_ROOT/.env"
if [ -e "$ENV" ]
then
  source "$CORDOVA_ROOT/.env"
fi

: ${VERSION:="1.0.0"}
TS=${1-`date +%s`}

echo "Building $TS"

ROOT=$CORDOVA_ROOT

BUILD=$ROOT/build
SRC=$ROOT/src
APP=$SRC/coffee/index.coffee
FONTS=$ROOT/node_modules/ionic-sdk/release/fonts
HAML=$SRC/haml
IOS=$ROOT/platforms/ios/www
WWW=$ROOT/www

BIN=$ROOT/node_modules/.bin
HAMLJS=$BIN/hamljs
BROWSERIFY=$BIN/browserify
PLEEEASE=$BIN/pleeease

rm -rf $BUILD
rm -rf $WWW/*
mkdir -p $BUILD/js

(echo "module.exports={build: $TS, version: \"$VERSION\"};" > "$SRC"/coffee/versioninfo.coffee) &
("$PLEEEASE" compile) &
("$HAMLJS" "$HAML" "$BUILD") &
(cp -r "$FONTS" "$BUILD"/fonts) &
("$BROWSERIFY" -t coffeeify --extension='.coffee' -d "$APP" -o "$BUILD"/js/all.js) &

wait

cp -r "$BUILD"/* "$WWW"
ionic emulate ios

$ROOT/osascript

# wait
#
# rsync -a -v --ignore-existing $IOS/* $BUILD
#
# ./node_modules/.bin/liveupdate-bundle $TS