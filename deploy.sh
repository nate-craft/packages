#!/usr/bin/sh

panic() {
    printf "\n%s\n" "$1"
    exit 1
}

# Automatically downloads file metadata, updates sha256sums + version field, and uploads to aur remote
upload_pkg() {
    (
        cd "$1" || panic "Could not cd into ${1}"
        rm -rf "${1}"*

        sed -i "s/^pkgver=.*/pkgver=${2}/" PKGBUILD || panic "Coud not set version"
        
        CHECKSUM=$(makepkg -g | tr '\n' ' ') || panic "Could not genererate checksum"
        sed -i "s/^sha256sums=.*/${CHECKSUM}/" PKGBUILD || panic "Could not set checksum"

        makepkg --sign -f || panic "Could not sign package"
        makepkg --printsrcinfo > .SRCINFO || panic "Could not generate SRCINFO file"

        git checkout -b master
        git add .
        git tag "$2"
        git commit -m "Version $2"
        git push --set-upstream origin master
    )
}

if [ "$1" = "--all" ]; then
    VERSION=$(curl -s "https://api.github.com/repos/nate-craft/auditorium/releases/latest" | jq -r .tag_name)
    upload_pkg "auditorium" "$VERSION" "auditorium-${VERSION}-x86_64-unknown-linux-gnu"
    upload_pkg "auditorium-minimal" "$VERSION" "auditorium-minimal-${VERSION}-x86_64-unknown-linux-gnu"

    VERSION=$(curl -s "https://api.github.com/repos/nate-craft/yt-feeds/releases/latest" | jq -r .tag_name)
    upload_pkg "yt-feeds" "$VERSION" "yt-feeds-${VERSION}-x86_64-unknown-linux-gnu"
elif [ -d "$1" ]; then
    VERSION=$(curl -s "https://api.github.com/repos/nate-craft/${1}/releases/latest" | jq -r .tag_name)
    upload_pkg "$1" "$VERSION" "${1}-${VERSION}-x86_64-unknown-linux-gnu"
else
    panic "A valid directory or '--all' must be specified"
fi

