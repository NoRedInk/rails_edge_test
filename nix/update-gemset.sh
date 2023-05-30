#!/usr/bin/env nix-shell
#!nix-shell -i bash -p zlib sqlite libiconv bundix

SCRIPT=`realpath $0`
CWD=`dirname $SCRIPT`

cd $CWD && bundix -m --ruby=ruby
