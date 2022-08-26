#!/bin/bash
#
# usage : ./generate_sha1.sh <FILE>
#
# 	Ex : ./generate_sha1.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2
#
echo "-------------------------------------------------------------"
echo "  GENERATING CHECKSUM SHA1 FOR CEF BUILD  "
echo "-------------------------------------------------------------"
if [ "$#" != "1" ]; then
	echo "Missing mandatory filename !"
    echo "Usage : ./generate_sha1.sh <DAZZL_CEF_BZ2_TARBALL>"
	echo "   Ex : ./generate_sha1.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2"
	exit
fi
TARBALL="$1"
REAL_TARBALL="`realpath ${TARBALL}`"
BASENAME_TARBALL="`basename ${REAL_TARBALL}`"
echo -n " - Checking '${REAL_TARBALL}' :"
if [ -e "${REAL_TARBALL}" ]; then
    echo " OK (well found, let's continue the process) "
	echo " - ${REAL_TARBALL} well found, let's continue the process"
	echo " - Generating sha1 for the tarball provided ${REAL_TARBALL}..."
	sha1sum "${REAL_TARBALL}"|awk '{ print $1 }'|tr -d '\n' > "${REAL_TARBALL}".sha1
	RET="$?"
	echo "RET=${RET}"
	if [ "${RET}" == "0" ] && [ -e "${REAL_TARBALL}.sha1" ]; then
		echo "The sha1 have been well generated!"
		echo "-> ${REAL_TARBALL}.sha1"
		ls -alh "${REAL_TARBALL}.sha1"
		file    "${REAL_TARBALL}.sha1"
		od -c   "${REAL_TARBALL}.sha1"
	else
		echo "[ERROR] Problem while generating the sha1!" 
	fi
else
	echo " NOK (Cannot found the cef tarball) "
fi
# — EOF
