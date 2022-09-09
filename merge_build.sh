#!/bin/bash
#
# merge_build.sh <FILE>
#
#	EX : ./merge_build.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2
#
#                104.4.18+g2587cf2+chromium-104.0.5112.81 / Chromium 104.0.5112.81
# dazzl build  : cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2
# spotfy build : cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2
#                cef_binary_104.4.18%2Bg2587cf2%2Bchromium-104.0.5112.81_linux64.tar.bz2
#                https://cef-builds.spotifycdn.com/index.html#linux64
#                https://cef-builds.spotifycdn.com/cef_binary_104.4.18%2Bg2587cf2%2Bchromium-104.0.5112.81_linux64.tar.bz2
#                https://cef-builds.spotifycdn.com/cef_binary_104.4.18%2Bg2587cf2%2Bchromium-104.0.5112.81_linux64.tar.bz2.sha1

echo "-------------------------------------------------------------"
echo "  MERGING THE DAZZL CEF BUILD WITH OFFICIAL SPOTIFY VANILLA  "
echo "-------------------------------------------------------------"
if [ "$#" != "1" ]; then
	echo "Missing mandatory filename !"
    echo "Usage : ./merge_build.sh <DAZZL_CEF_BZ2_TARBALL>"
	echo "   Ex : ./merge_build.sh cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2"
	exit 1
fi
ORIG_TARBALL="$1"
TIRET_MATCH="%2B"
TIRET_REPL="+"
REAL_TARBALL="`realpath ${ORIG_TARBALL}`"
BASENAME_TARBALL="`basename ${ORIG_TARBALL}`"
#echo " - ORIG_TARBALL=${ORIG_TARBALL} "
#echo " - REAL_TARBALL=${REAL_TARBALL} "
#echo " - BASENAME_TARBALL=${BASENAME_TARBALL} "
if [ -e ${REAL_TARBALL} ]; then
    if [[ "${ORIG_TARBALL}" == *"%2B"* ]]; then
        TARBALL_ESCAPED="${ORIG_TARBALL}"
        echo " - The filename '${ORIG_TARBALL}' is excaped, unescaped it first..."
        #TARBALL=$(tr -s %2B - <<< ${TARBALL})
        TARBALL=$(sed 's/'"$TIRET_MATCH"'/'"$TIRET_REPL"'/g' <<< "$ORIG_TARBALL")
        mv ./${ORIG_TARBALL} ./${TARBALL}
    else
        TARBALL="${ORIG_TARBALL}"
        TARBALL_ESCAPED=$(sed 's/'"$TIRET_REPL"'/'"$TIRET_MATCH"'/g' <<< "$REAL_TARBALL")
    fi
else
    echo " - Cannot found the filename ${ORIG_TARBALL} !"
    exit 1  
fi
REAL_TARBALL="`realpath ${TARBALL}`"
BASENAME_TARBALL="`basename ${REAL_TARBALL}`"
#echo " - TARBALL=${TARBALL} "
#echo " - REAL_TARBALL=${REAL_TARBALL} "
#echo " - BASENAME_TARBALL=${BASENAME_TARBALL} "
#echo " - TARBALL_ESCAPED=${TARBALL_ESCAPED} "
echo -n " - Checking '${BASENAME_TARBALL}' :"
if [ -e "${REAL_TARBALL}" ]; then
    echo " OK (well found, let's continue the process)"

    # --- Extract information from filename
    EXTENSION="tar.bz2"
    PREFIX_1="`echo ${BASENAME_TARBALL}|awk -F"_" '{ print $1 }'`"
    PREFIX_2="`echo ${BASENAME_TARBALL}|awk -F"_" '{ print $2 }'`"
    CEF_VERSION="`echo ${BASENAME_TARBALL}|awk -F"_" '{ print $3 }'`"
    SUFFIX="`echo ${BASENAME_TARBALL}|awk -F_ '{ print $4 }'`"
    FILENAME="`echo ${BASENAME_TARBALL}|awk -F.${EXTENSION} '{ print $1 }'`"
    
    # --- Analyze filename's pattern
    #echo " - PREFIX_1=${PREFIX_1} "
    #echo " - PREFIX_2=${PREFIX_2} "
    echo " - CEF version found='${CEF_VERSION}' "
    #echo " - SUFFIX=${SUFFIX} "
    #echo " - FILENAME=${FILENAME} "
    echo -n " - Checking filename pattern :"
    if [ "${PREFIX_1}" == "cef" ] && [ "${PREFIX_2}" == "binary" ] && [ "${CEF_VERSION}" != "" ] && [ "${SUFFIX}" == "linux64.tar.bz2" ]; then
       echo " OK "
    else
        echo " NOK "
        echo " - Expected format : cef_binary_<CEF_VERSION>_linux64.tar.bz2 "
        echo "                     cef_binary_<CEF_RELEASE>+<CEF_SHA1>+chromium-<CHROMIUM_RELEASE>_linux64.tar.bz2 "
        echo "   EX: cef_binary_104.4.18+g2587cf2+chromium-104.0.5112.81_linux64.tar.bz2 "
        echo "                     CEF_RELEASE      = 104.4.18 "
        echo "                     CEF_SHA1         = g2587cf2 "
        echo "                     CHROMIUM_RELEASE = 104.0.5112.81 "
        exit 1
    fi

    # --- Check mime type 
    # file cef_binary_104.4.18%2Bg2587cf2%2Bchromium-104.0.5112.81_linux64.tar.bz2
    # cef_binary_104.4.18%2Bg2587cf2%2Bchromium-104.0.5112.81_linux64.tar.bz2: bzip2 compressed data, block size = 900k
    TARBALL_COMPRESSION_TYPE="`file ${REAL_TARBALL}|awk '{ print $2 }'`"
    EXPECTED_COMPRESSION_TYPE="bzip2"
    echo -n " - Checking compression type :"
    if [ "${TARBALL_COMPRESSION_TYPE}" != "${EXPECTED_COMPRESSION_TYPE}" ]; then
        echo 
        echo " NOK (tar.bz2 was expected) ! "
        exit 1
    else
        echo " OK (${EXPECTED_COMPRESSION_TYPE})"
    fi

    # --- Create temp directory
    TMP_WORK_DIR="`mktemp -d /tmp/cef-${CEF_VERSION}-XXXXX`"
    echo " - Temporarily work directory=${TMP_WORK_DIR}"
    if [ -d "${TMP_WORK_DIR}" ]; then
        cd ${TMP_WORK_DIR}/

        # --- Make a copy of the dazzl cef build
        echo " - Moving the dazzl build tarball within the working directory..."
        cp ${REAL_TARBALL} .
        mv ${BASENAME_TARBALL} dazzl_${BASENAME_TARBALL}
        if [ -e "dazzl_${BASENAME_TARBALL}" ]; then
            tar -xf "dazzl_${BASENAME_TARBALL}"
            if [ -d "${TMP_WORK_DIR}/${FILENAME}" ]; then
                #echo " FROM : ${TMP_WORK_DIR}/${FILENAME} "
                #echo " TO   : ${TMP_WORK_DIR}/dazzl_${FILENAME} "
                mv ${TMP_WORK_DIR}/${FILENAME} ${TMP_WORK_DIR}/dazzl_${FILENAME}
            else
                echo " -    Cannot found the ${TMP_WORK_DIR}/${FILENAME} tarball"
            fi
        else
            echo " - Cannot found the dazzl_${BASENAME_TARBALL} tarball!"
            exit 1
        fi  

        # --- Download the spotify version
        TARBALL_URL=$(basename ${TARBALL_ESCAPED})
        TARBALL_FINAL=$(basename ${REAL_TARBALL})
        #echo " - TARBALL_URL=${TARBALL_URL} "
        URL_SPOTIFY="https://cef-builds.spotifycdn.com/${TARBALL_URL}"
        echo " - Downloading ${TARBALL} from https://cef-builds.spotifycdn.com ..."
        #echo " - URL_SPOTIFY=${URL_SPOTIFY} "
        wget --no-verbose ${URL_SPOTIFY} --output-document="${TMP_WORK_DIR}/spotify-${TARBALL_FINAL}"
        #wget ${URL_SPOTIFY} --output-document="${TMP_WORK_DIR}/spotify-${TARBALL_FINAL}"
        RET="$?"
        if [ "${RET}" == "0" ] && [ -e "${TMP_WORK_DIR}/spotify-${TARBALL_FINAL}" ]; then
            tar -xf ${TMP_WORK_DIR}/"spotify-"${TARBALL_FINAL}
        else
            echo " - cannot found the spotify-${TARBALL_FINAL} tarball!"
            exit 1
        fi

        # --- Listing working directory
        ls -alh ${TMP_WORK_DIR}/

        # --- Merging file from dazzl-build to the spotify
        FROM="${TMP_WORK_DIR}/dazzl_${FILENAME}"
        TO="${TMP_WORK_DIR}/${TARBALL_FINAL}"
        echo " - FROM=${FROM} "
        echo " - TO=${TO} "




        # TBD






        # --- Recreate a tarball that can be deploy to the DAZZL S3 BUCKET
        echo -n " - Regenerate the final archive (${EXPECTED_COMPRESSION_TYPE}) :"
        tar -cvjSf ${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2 ${TO}
        if [ -e ${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2 ]; then
            echo " OK "
        else
            echo " NOK "
            exit 1
        fi

        # --- Generate a sha1 checksum for the final tarball
        sha1sum "${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2"|awk '{ print $1 }'|tr -d '\n' > "${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1"
        RET="$?"
	    echo "RET=${RET}"
	    if [ "${RET}" == "0" ] && [ -e "${REAL_TARBALL}.sha1" ]; then
		    echo " - The sha1 have been well generated!"
		    echo "-> ${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1"
		    ls -alh "${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1"
		    file    "${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1"
		    od -c   "${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1"
	    else
		    echo "[ERROR] Problem while generating the sha1!" 
	    fi

        # --- Display final files :
        echo " - Final files to upload to the s3 bucket : "
        echo "      TARBALL : ${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2 "
        echo "      SHA1    : ${TMP_WORK_DIR}/${TARBALL_FINAL}.tar.bz2.sha1 "

        # --- Provide information to validate the cef build :
        echo " - Once uploaded to the dazzl s3 bucket, you can build gstcefsrc and run the following gstreamer pipelines : "
        echo " "
        echo " 0. Requirements & build : "
        echo " "
        echo "   - Clone the git repo : git clone https://github.com/centricular/gstcefsrc.git && cd gstcefsrc/ "
        echo "   - Edit the CMakeLists.txt in order to specify the '${CEF_VERSION}' release "
        echo "   - Create a build directory : mkdir build && cd build "
        echo "   - Generate the Makefile : cmake -G \"Unix Makefiles\" -DCMAKE_BUILD_TYPE=Release .. "
        echo "   - Launch the build of the gst module : make "
        echo " "
        echo " 1. Inspect the gst modules : "
        echo " "
        echo "    GST_PLUGIN_PATH=Release:$ GST_PLUGIN_PATH gst-inspect-1.0 cefsrc "
        echo "    GST_PLUGIN_PATH=Release:$ GST_PLUGIN_PATH gst-inspect-1.0 cefdemux "
        echo " "
        echo " 2. Launch a simple pipeline : "
        echo " "
        echo "    GST_PLUGIN_PATH=Release:$ GST_PLUGIN_PATH gst-launch-1.0 \ "
        echo "    cefsrc url=\"https://soundcloud.com/platform/sama\" ! \ "
        echo "    video/x-raw, width=1920, height=1080, framerate=60/1 ! cefdemux name=d d.video ! \ "
        echo "    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! videoconvert ! \ "
        echo "    xvimagesink audiotestsrc do-timestamp=true is-live=true  volume=0.00 ! audiomixer name=mix ! \ "
        echo "    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! audioconvert ! pulsesink \ "
        echo "    d.audio ! mix. "
        echo " "
        echo " 3. Validate the h264 feature : "
        echo " "
        echo "    GST_PLUGIN_PATH=Release:$ GST_PLUGIN_PATH gst-launch-1.0 \ "
        echo "    cefsrc url=\"https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4\" ! \ "
        echo "    video/x-raw, width=1920, height=1080, framerate=60/1 ! cefdemux name=d d.video ! \ "
        echo "    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! videoconvert ! \ "
        echo "    xvimagesink audiotestsrc do-timestamp=true is-live=true  volume=0.00 ! audiomixer name=mix ! \ "
        echo "    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! audioconvert ! pulsesink \ "
        echo "    d.audio ! mix. "
        echo " "
    else
        echo " - Cannot found the working directory!"
    fi
else
	echo " - Cannot found the cef tarball!"
    exit 1
fi
# — EOF