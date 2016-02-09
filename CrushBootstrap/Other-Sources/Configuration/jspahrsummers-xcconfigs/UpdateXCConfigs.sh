#!/bin/bash

set -e

if [ "$1" == "-q" ]; then
    QUIET=true
    CURL_QUIET_OPT=s
else
    QUIET=false
    CURL_QUIET_OPT=
fi

say() {
    $QUIET || echo $*
}

cd "$(dirname "$0")"

say "Grabbing latest xcconfigs..."

curl -fSL#$CURL_QUIET_OPT 'https://github.com/jspahrsummers/xcconfigs/archive/master.tar.gz' | tar xz --strip-components=1

# No commit checking stuff in quiet mode
$QUIET && exit 0

porcelain_status=$(git status --porcelain .)
if [ -n "$porcelain_status" ]; then
    printf "There were updates! Would you like to commit them [Y/n]? "

    REPLY=dummy
    until [ -z "$REPLY" -o "$REPLY" == "y" -o "$REPLY" == "n" -o "$REPLY" == "Y" -o "$REPLY" == "N" ]; do
        read -n1 -s
    done

    [ -z "$REPLY" ] && REPLY=y

    echo $REPLY

    if [ "$REPLY" == "y" -o "$REPLY" == "Y" ]; then
        git add .
        git commit . -m "Update xcconfigs"
    fi
fi
