#!/bin/bash
set -e -x

bash ./run-pkgcheck.bash "${@}" |& awk -f "$(dirname "${0}")"/parse-pcheck-output.awk

[[ ${PIPESTATUS[0]} == 0 ]]
