#!/bin/sh

set -xe

if which dot 2>&1 > /dev/null ; then
	dot -T png arch.dot -o arch.png
	if which optipng 2>&1 > /dev/null; then
		optipng -o7 -v arch.png
	fi
else
	echo 'You need to install graphviz first'
fi
