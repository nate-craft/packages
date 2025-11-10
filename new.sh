#!/usr/bin/env sh

panic() {
    printf "$1"
    exit 1
}

if [ -z "$1" ]; then
    panic "No repository name was provided!"
fi

git clone ssh://aur@aur.archlinux.org/${1}.git || panic "Could not clone AUR repository"
mkdir "$1"
cp reference/PKGBUILD "$1" || panic "Could not copy over PKGBUILD"
sed -i "s/PACKAGE_NAME/${1}/g" "${1}/PKGBUILD" || panic "Could not replace package name in PKGBUILD"

echo "[submodule \"${1}\"]
	path = \"${1}\"
	url = ssh://aur@aur.archlinux.org/${1}.git
" >> .gitmodules || panic "Could not add submodule for ${1}"
