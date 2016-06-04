#!/bin/bash
set -e -x

JOB=${1}
NO_JOBS=${2}

if [[ ! ${JOB} || ! ${NO_JOBS} ]]; then
	# simple whole-repo run
	exec pkgcheck -r gentoo --reporter XmlReporter \
		ld imlate -d unstable_only -d cleanup -d stale_unstable \
		-d deprecated \
		-p stable --profiles-disable-deprecated
elif [[ ${JOB} == global ]]; then
	# global check part of split run
	exec pkgcheck -r gentoo --reporter XmlReporter \
		-c UnusedGlobalFlags -c UnusedLicense -c RepoProfilesReport
else
	# keep the category scan silent, it's so loud...
	set +x
	cx=0
	cats=()
	for c in $( cd metadata/md5-cache; du $(<../../profiles/categories) | sort -n -r | cut -d$'\t' -f2)
	do
		if [[ $(( cx++ % ${NO_JOBS} )) -eq ${JOB} ]]; then
			cats+=( "${c}/*" )
		fi
	done
	set -x

	exec pkgcheck -r gentoo --reporter XmlReporter "${cats[@]}" \
		-d imlate -d unstable_only -d cleanup -d stale_unstable \
		-d deprecated -d UnusedGlobalFlags -d UnusedLicense \
		-p stable --profiles-disable-deprecated
fi
