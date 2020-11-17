#!/bin/bash -e
## 
# machines can be mx5-pt etc.

if [ -z $1 ]; then
echo "Missing in parameter to target machine (mx5-**)"
exit 1
fi

export DIR_WORK=$PWD/../
export BUILD_TAG=debug

export PLATFORM_VERSION="$(git -C $DIR_WORK.repo/manifests rev-parse --short HEAD)"
export PLATFORM_VERSION_DETAILS="$(repo forall -c 'echo $REPO_PATH\nLREV: $REPO_LREV\nRREV: $REPO_RREV; git diff --stat -b $REPO_LREV..HEAD ; echo -n "Commit: " ; git rev-parse HEAD ; echo -n "Uncommited changes: " ; git status -b -s ; git diff --stat -b ; echo ')"
echo "building with repo versions: $PLATFORM_VERSION"

#echo  "$PLATFORM_VERSION_DETAILS"

export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE BUILD_TAG PLATFORM_VERSION PLATFORM_VERSION_DETAILS"

export TEMPLATECONF=$PWD/../layers/meta-hostmobility-distro/conf
if [ ! -d "$TEMPLATECONF" ]; then
  echo "Directory to TEMPLATECONF could not be found"
  echo "Tried this path $TEMPLATECONF"
  exit 1
fi

export MACHINE=$1

env
cd $DIR_WORK
echo $DIR_WORK

#make sure that we get a clean rerun so remove conf folder and file (will be created again on source) 
if [ -z "$2" ]; then
echo No clean
else
if [ "$2" != "defconfig" ]; then
    sudo rm -r build/conf
    sudo rm -r "build/tmp-glibc" || echo "skip remove tmp-glibc"
    sudo rm -r "deploy" || echo "skip remove deploy"
  fi
fi

source layers/openembedded-core/oe-init-build-env build;
grep "commercial" conf/local.conf || echo 'LICENSE_FLAGS_WHITELIST += "commercial"' >> conf/local.conf;
#grep "version-going-backwards" conf/local.conf || echo 'ERROR_QA_remove = "version-going-backwards"' >> conf/local.conf;

echo "Building target machine: $1";

if [ "$2" == "defconfig" ]; then
  echo "make defconfig..."
  bitbake virtual/kernel -c menuconfig || exit 1
  bitbake virtual/kernel -c savedefconfig || exit 1
  exit 0

fi

#bitbake -c cleanall mobility-image || exit 1 
bitbake -k console-hostmobility-image || exit 1
bitbake -k mobility-image-xfce || exit 1
#bitbake mobility-image-console -f -c compile || exit 1 
#bitbake mobility-image-console -c populate_sdk
exit 0
##extra later
#cd ../mx5-deploy
#source deploy_target_platform.bash $1 || exit 1
#exit 0

