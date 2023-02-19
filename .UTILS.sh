#!/bin/bash

# I made this stuff a long time ago, so I dont really remember how it all works.
# Good luck trying to decode this though!

A_Has() {
    search_string=$1
    shift
    if grep -q "$search_string" "$@"; then
        return 0
    fi
    return 1
}

isnum() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    fi
    return 1
}

isstr() {
    if [[ $1 =~ ^[a-zA-z]+$ ]]; then
        return 0
    fi
    return 1
}

shrinkArr() {
    echo "$*"
}

applyBackspaces() {
    local input=$*

    for ((i = 0; i < ${#input}; i++)); do
        char="${input:i:1}"
        isstr $char && continue
        
    done
}

# Converts file paths
toWin() {
    if [[ $* == "" ]]; then
        wslpath -w "$(pwd)"
    else
        wslpath -w "$1"
    fi
}

toWsl() {
    local path
    if [[ $* == "" ]]; then
        path="$(wslpath -u "$(pwd)")"
    else
        path="$(wslpath -u "$1")"
    fi
    printf "%q" "$path" | tr -d "'"
}