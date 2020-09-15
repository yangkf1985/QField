#!/usr/bin/env bash
#sudo apt install qttools5-dev-tools
#sudo apt install qt5-default

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../version_number.sh

ls -l ${CI_BUILD_DIR}/i18n/qfield_en.ts
ls -l ${CI_BUILD_DIR}/i18n/qfield_bg.ts
ls -l ${CI_BUILD_DIR}/i18n/qfield_en.qm
ls -l ${CI_BUILD_DIR}/i18n/qfield_bg.qm

echo == update now
lupdate-qt5 -recursive ${DIR}/../.. -ts ${DIR}/../../i18n/qfield_en.ts

echo ==grep Trans-test-ta
grep -Ri Trans-test-ta ${CI_BUILD_DIR}
grep -Ri Trans-test-ta ${DIR}/../..
echo ==grep Trans-test-ta

echo === -1 
echo ${CI_BUILD_DIR}
echo ${DIR}
ROOTDIR=${DIR}/../..
echo $ROOTDIR

ls -l ${CI_BUILD_DIR}/i18n/qfield_en.ts
ls -l ${CI_BUILD_DIR}/i18n/qfield_bg.ts

echo ==================1
grep -Ri Trans-test-ta ${CI_BUILD_DIR}/i18n/qfield_en.ts
echo ==================1

echo ==================2
grep -Ri Trans-test-ta ${CI_BUILD_DIR}/i18n/qfield_bg.ts
echo ==================2


# release only if the branch is master
if [[ ${CI_BRANCH} = master ]]; then
  tx push --source
fi

# release only if the branch is master
if [[ ${CI_BRANCH} = trans-test ]]; then
  tx push --source
fi
