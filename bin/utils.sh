#!/bin/bash

print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

print_in_red() {
    print_in_color "$1" 1
}

print_in_green() {
    print_in_color "$1" 2
}

print_in_yellow() {
    print_in_color "$1" 3
}

print_in_blue() {
    print_in_color "$1" 4
}

print_success() {
    print_in_green "   [✔] $1\n"
}

print_question() {
    print_in_yellow "   [?] $1"
}

print_warning() {
    print_in_yellow "   [!] $1\n"
}

print_error() {
    print_in_red "   [✖] $1 $2\n"
}

print_error_stream() {
    while read -r line; do
        print_error "↳ ERROR: $line"
    done
}

print_result() {

    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"

}

ask() {
    print_question "$1"
    read -r
}

ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -r -n 1
    printf "\n"
}

get_answer() {
    printf "%s" "$REPLY"
}

answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

cmd_exists() {
    command -v "$1" &> /dev/null
}

kill_all_subprocesses() {

    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done

}

show_spinner() {

    local -r FRAMES='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    local -r NUMBER_OR_FRAMES=${#FRAMES}

    local -r PID="$1"

    local -r MSG="$2"

    local i=0
    local frameText=""

    # Display spinner while the process are being executed.

    while kill -0 "$PID" &>/dev/null; do

        frameText="   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"

        printf "%s" "$frameText"

        sleep 0.2

        printf "\r"

    done
}

execute() {

    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

    local exitCode=0
    local cmdsPID=""

    # If the current process is ended,
    # also end all its subprocesses.
    trap "kill_all_subprocesses" "EXIT"

    # Execute commands in background
    eval "$CMDS" 1> /dev/null 2> "$TMP_FILE" &
    cmdsPID=$!

    # Show a spinner if the commands
    show_spinner "$cmdsPID" "$MSG"

    # Wait for the commands to no longer be executing
    # in the background, and then get their exit code.
    wait "$cmdsPID" &> /dev/null
    exitCode=$?

    # Print output based on what happened.
    print_result $exitCode "$MSG"

    if [ $exitCode -ne 0 ]; then
        print_error_stream < "$TMP_FILE"
    fi

    rm -rf "$TMP_FILE"

    return $exitCode

}

get_os() {

    local os=""
    local kernelName=""

    kernelName="$(uname -s)"

    if [ "$kernelName" == "Darwin" ]; then
        os="macos"
    elif [ "$kernelName" == "Linux" ] && [ -e "/etc/os-release" ]; then
        os="$(. /etc/os-release; printf "%s" "$ID")"
    else
        os="$kernelName"
    fi

    printf "%s" "$os"

}

get_os_version() {

    local os=""
    local version=""

    os="$(get_os)"

    if [ "$os" == "macos" ]; then
        version="$(sw_vers -productVersion)"
    elif [ -e "/etc/os-release" ]; then
        version="$(. /etc/os-release; printf "%s" "$VERSION_ID")"
    fi

    printf "%s" "$version"

}

get_here() {

    local -r here="$(dirname "${BASH_SOURCE[1]}")"

    printf "%s" "$here"

}

skip_questions() {

     while :; do
        case $1 in
            -y|--yes) return 0;;
                   *) break;;
        esac
        shift 1
    done

    return 1

}

create_symlinks() {

    local -r sourceFile="$1"
    local -r targetFile="$2"
    local -r skipQuestions="$3"

    if [ ! -e "$targetFile" ] || $skipQuestions; then

        mkdir -p $(dirname $targetFile)

        execute \
            "ln -sf $sourceFile $targetFile" \
            "$sourceFile → $targetFile"

    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
        print_success "$sourceFile → $targetFile"

    else

        if ! $skipQuestions; then

            ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"

            if answer_is_yes; then

                rm -rf "$targetFile"

                execute \
                    "ln -fs $sourceFile $targetFile" \
                    "$sourceFile → $targetFile"

            else
                print_error "$sourceFile → $targetFile"

            fi

        fi
    fi

}
