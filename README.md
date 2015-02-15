This repository provides a quick set of scripts for QA testing of Gentoo
repositories. The checks use pkgcore's pcheck tool with provided output
post-processing script.

It is recommended to fetch the scripts directly in your .travis.yml
and run them afterwards. This allows us to update them according to
changes in pkgcore without you having to update .travis.yml all
the time.

Example .travis.yml:

	language: python
	python:
	  - 2.7

	install:
	  - wget -O - "https://github.com/gentoo/travis-repo-checks/archive/master.tar.gz" | tar -xz
	  - bash travis-repo-checks-master/prepare-tests.bash

	script:
	  - bash travis-repo-checks-master/run-tests.bash

This runs a single pcheck job for the whole repository.

Example with multiple jobs:

	language: python
	python:
	  - 2.7

	env:
	  - JOB=global
	  - JOB=0
	  - JOB=1
	  - JOB=2
	  - JOB=3

	install:
	  - wget -O - "https://github.com/gentoo/travis-repo-checks/archive/master.tar.gz" | tar -xz
	  - bash travis-repo-checks-master/prepare-tests.bash

	script:
	  - bash travis-repo-checks-master/run-tests.bash ${JOB} 4

Note that you need to pass job count to `run-tests.bash`, and you should
add an additional `global` job to handle the few checks that can be done
on full repository only.
