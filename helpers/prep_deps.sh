#!/bin/bash
set -xeo pipefail
source build-config.sh
source helpers/build-common.sh
test -f .DIND && find_docker
echo "DOCKER BINARY IS AT ${DOCKERBIN}"
test -z ${DOCKERBIN} && exit 1
echo "DOCKER BINARY IS AT ${DOCKERBIN}"
echo "DOCKER BINARY IS AT ${DOCKERBIN}"
do_windows (){
 test -f helpers/hid.pyd || build_win32trezor
# for i in __init__.py darkcoin_hash.pyd groestlcoin_hash.pyd ltc_scrypt.pyd  neoscrypt.pyd  qubit_hash.pyd skeinhash.pyd ; do
 # test -f helpers/coinhash/${i} || touch buildcoinhash.yes
# done
 #test -f buildcoinhash.yes && buildCoinHash 
# test -f buildcoinhash.yes && rm buildcoinhash.yes
 # one shot to buildCoinhash to build x11_hash for dash
 buildCoinHash
 echo "do_windows done"
}

# clone python-trezor so we have it for deps, and to include trezorctl.py 
# for pyinstaller to analyze
test -d python-trezor || git clone https://github.com/mazaclub/python-trezor
cd python-trezor
git checkout rev
cd ../
# prepare repo for local build
test -f prepared || ./helpers/prepare_repo.sh
./make_requirements_txt.sh
#get_archpkg

# build windows C extensions
#if [ "$OS" = "buildWindows" ] ; then
# do_windows
#elif [ "${OS}" = "build.sh" ] ; then 
# do_windows
#fi
do_windows
echo "Windows C Extensions compiled"

# Build docker images
$DOCKERBIN images|awk '{print $1":"$2}'|grep "mazaclub/electrum-dash-winbuild:${VERSION}" || buildImage winbuild
$DOCKERBIN images|awk '{print $1":"$2}'|grep "mazaclub/electrum-dash-release:${VERSION}" || buildImage release
# touch FORCE_IMG_BUILD if you want to 
test -f FORCE_IMG_BUILD &&  buildImage winbuild
test -f FORCE_IMG_BUILD &&  buildImage release
touch prepped
echo "prepared"
