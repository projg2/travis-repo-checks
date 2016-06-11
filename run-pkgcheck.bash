#!/bin/bash
set -e -x

JOB=${1}
NO_JOBS=${2}

SKIPPED_CHECKS=(
	# maintainer info rather than global QA
	-d imlate
	-d unstable_only
	-d cleanup
	-d stale_unstable
	# a lot of output, not much helpfulness
	-d deprecated
)

if [[ ! ${JOB} || ! ${NO_JOBS} ]]; then
	# simple whole-repo run
	exec pkgcheck -r gentoo --reporter XmlReporter \
		-p stable --profiles-disable-deprecated \
		"${SKIPPED_CHECKS[@]}"
elif [[ ${JOB} == global ]]; then
	# global check part of split run
	exec pkgcheck -r gentoo --reporter XmlReporter \
		-c UnusedGlobalFlagsCheck -c UnusedLicenseCheck -c UnusedMirrorsCheck -c RepoProfilesReport
else
	# keep the category scan silent, it's so loud...
	set +x
	cx=0
	cats=()
	for c in $( cd metadata/md5-cache; du --apparent $(<../../profiles/categories) | sort -n -r | cut -d$'\t' -f2)
	do
		if [[ $(( cx++ % ${NO_JOBS} )) -eq ${JOB} ]]; then
			cats+=( "${c}/*" )
		fi
	done
	set -x

	exec pkgcheck -r gentoo --reporter XmlReporter "${cats[@]}" \
		-p stable --profiles-disable-deprecated \
		"${SKIPPED_CHECKS[@]}"
fi
