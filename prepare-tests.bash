#!/bin/bash
set -e -x

# prepare dirs we need
sudo mkdir -p /etc/portage /var/db/pkg
# add write permissions to avoid too much sudo
sudo chmod a+rwX /etc/passwd /etc/group /etc/portage /usr

# create needed users & groups
echo "portage:x:250:250:portage:/var/tmp/portage:/bin/false" >> /etc/passwd
echo "wheel::10:${USER}" >> /etc/group
echo "portage::250:portage,travis" >> /etc/group

# install snakeoil as pkgcore dep
# snakeoil: we need explicit --install-headers because of pip bug
#   -> https://github.com/pypa/pip/pull/2421
pip install "https://github.com/pkgcore/snakeoil/archive/master.tar.gz" \
	--install-option="--install-headers=${VIRTUAL_ENV}/include/snakeoil"

# fetch pkgcore & pkgcheck
# their setup.py files are incompatible with pip
wget -O - "https://github.com/pkgcore/pkgcore/archive/master.tar.gz" | tar -xz
wget -O - "https://github.com/pkgcore/pkgcheck/archive/master.tar.gz" | tar -xz

# install pkgcore
cd pkgcore-master
git init
python setup.py build_ext -I "${VIRTUAL_ENV}"/include
python setup.py install --disable-man-pages --disable-html-docs
cd -

# install pkgcheck
cd pkgcheck-master
git init
python setup.py install
cd -

# finish preparing system-wide config
sudo cp -rv "${VIRTUAL_ENV}"/share/* /usr/share/
ln -s "${PWD}"/profiles/base /etc/portage/make.profile
ln -s "${PWD}" /usr/portage
