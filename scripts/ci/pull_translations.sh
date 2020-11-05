#!/bin/bash

echo "::group::tx-pull"

if [[ ${CI_SECURE_ENV_VARS} = true ]]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  source ${DIR}/../version_number.sh
  
  tx pull --all --force
  
  for x in android/res/values-*_*;do mv $x $(echo $x | sed -e 's/_/-r/') ;done
  
  find ${DIR}/i18n -type f -name "*.ts" -exec lrelease "{}" \;
  echo checking japanese grep -Ri -B1 -A2 "Show on map canvas" i18n/qfield_ja.ts
  grep -Ri -B1 -A2 "Show on map canvas" ${DIR}/qfield_ja.ts
fi

echo "::endgroup::"
