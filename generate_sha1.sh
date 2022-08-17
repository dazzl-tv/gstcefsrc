#!/bin/bash
#
# usage : ./generate_sha1.sh <FILE>
#
# 	Ex : ./generate_sha1.sh cef_binary_103.0.12+g8eb56c7+chromium-103.0.5060.134_linux64.tar.bz2
#
TARBALL="$1"
if [ -e "${TARBALL}" ]; then
	echo " - Generating sha1 for the tarball provided ${TARBALL}..."
	sha1sum "${TARBALL}"|awk '{ print $1 }'|tr -d '\n' > "${TARBALL}".sha1
	RET="$?"
	echo "RET=${RET}"
	if [ "${RET}" == "0" ] && [ -e "${TARBALL}.sha1" ]; then
		echo "The sha1 have been well generated!"
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
