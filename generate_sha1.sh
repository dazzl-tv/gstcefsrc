#!/bin/bash
#
# usage : ./generate_sha1.sh <FILE>
#
# 	Ex : ./generate_sha1.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2
#

if [ "$#" != "1" ]; then
	echo "Missing mandatory filename !"
    echo "Usage : ./generate_sha1.sh <DAZZL_CEF_BZ2_TARBALL>"
	echo "   Ex : ./generate_sha1.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2"
	exit
fi
TARBALL="$1"
if [ -e "${TARBALL}" ]; then
	echo " - Generating sha1 for the tarball provided ${TARBALL}..."
	sha1sum "${TARBALL}"|awk '{ print $1 }'|tr -d '\n' > "${TARBALL}".sha1
	RET="$?"
	echo "RET=${RET}"
	if [ "${RET}" == "0" ] && [ -e "${TARBALL}.sha1" ]; then
		echo "The sha1 have been well generated!"
		echo "-> ${TARBALL}.sha1"
		ls -alh "${TARBALL}.sha1"
		file    "${TARBALL}.sha1"
		od -c   "${TARBALL}.sha1"
	else
		echo "[ERROR] Problem while generating the sha1!" 
	fi
else
	echo "Cannot found the cef tarball!"
fi
# — EOF
