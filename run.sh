#!/bin/bash
export QFIELD_SDK_VERSION=20191001
docker run -v $(pwd):/usr/src/qfield -e "BUILD_FOLDER=build-arm64_v8a" -e "ARCH=arm64_v8a" -e 'STOREPASS=123456' -e "KEYNAME=opengis.ch publishing key" -e 'KEYPASS=123456' -e "VERSION=1.2.0" opengisch/qfield-sdk:${QFIELD_SDK_VERSION} /usr/src/qfield/scripts/docker-build.sh

adb install -r build-arm64_v8a/out/build/outputs/apk/release/out-release-signed.apk
adb shell am start -n ch.opengis.qfield/ch.opengis.qfield.QFieldActivity
sleep 3
adb logcat --pid=$(adb shell pidof -s ch.opengis.qfield) 
