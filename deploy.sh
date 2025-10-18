#!/usr/bin/sh

panic() {
    printf "\n%s\n" "$1"
    exit 1
}

# Automatically downloads file metadata, updates sha256sums + version field, and uploads to aur remote
upload_auditorium() {
    (
        cd "$1" || panic "Could not cd into ${1}"
        CHECKSUM=$(makepkg -g) || panic "Could not genererate checksum"

        sed -i "s/^pkgver=.*/pkgver=${2}/" PKGBUILD || panic "Coud not set version"
        sed -i "s/^sha256sums=.*/${CHECKSUM}/" PKGBUILD || panic "Could not set checksum"
        makepkg --sign -f || panic "Could not sign package"
        makepkg --printsrcinfo > .SRCINFO || panic "Could not generate SRCINFO file"

        git add .
        git commit -m "Version $2"
        git push --set-upstream aur master
    )
}

VERSION=$(curl -s "https://api.github.com/repos/nate-craft/auditorium/releases/latest" | jq -r .tag_name)
upload_auditorium "auditorium" "$VERSION" "auditorium-v${VERSION}-linux-amd64"
upload_auditorium "auditorium-minimal" "$VERSION" "auditorium-minimal-v${VERSION}-linux-amd64"

