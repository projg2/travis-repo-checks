#!/bin/bash
set -e -x

JOB=${1}
NO_JOBS=${2}

if [[ ! ${JOB} || ! ${NO_JOBS} ]]; then
	# simple whole-repo run
	pcheck -r /usr/portage --reporter FancyReporter \
		-d imlate -d unstable_only -d cleanup -d stale_unstable \
		--profile-disable-dev --profile-disable-exp
elif [[ ${JOB} == global ]]; then
	# global check part of split run
	pcheck -r /usr/portage --reporter FancyReporter \
		-c UnusedGlobalFlags -c UnusedLicense
else
	# keep the category scan silent, it's so loud...
	set +x
	cx=0
	cats=()
	for c in $(<profiles/categories); do
		if [[ $(( cx++ % ${NO_JOBS} )) -eq ${JOB} ]]; then
			cats+=( "${c}/*" )
		fi
	done
	set -x

	set -- "${cats[@]}"
	while [[ -n ${@} ]]; do
		pcheck -r /usr/portage --reporter FancyReporter "${@:1:8}" \
			-d imlate -d unstable_only -d cleanup -d stale_unstable \
			--profile-disable-dev --profile-disable-exp
		shift 8 || break
	done
fi |& awk -f "$(dirname "${0}")"/parse-pcheck-output.awk

[[ ${PIPESTATUS[0]} ]]
