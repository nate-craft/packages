#!/usr/bin/env sh

panic() {
    printf "\n%s\n" "$1"
    exit 1
}

pull() {
    cd "$1" || panic "Could not move into dir ${1}"
    git init 
    git checkout -b master
    git remote add origin ssh://aur@aur.archlinux.org/"$1".git
    git pull origin master
    cd ..
}

if [ "$1" = "--all" ]; then
    pull auditorium
    pull auditorium-minimal
    pull yt-feeds
elif [ -d "$1" ]; then
    pull "$1"
elif [ -z "$1" ]; then
    panic "A valid directory or '--all' must be specified"
else
    ./new.sh "$1"
fi

