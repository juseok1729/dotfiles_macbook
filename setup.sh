#!/bin/bash

declare skipQuestions=false

cd "$(dirname "${BASH_SOURCE[0]}")"

. "bin/utils.sh"

main() {

    # answer yes to all questions
    skip_questions "$@" && skipQuestions=true

    # 1. symlink configs
    bash "bin/symlink_configs.sh" "$@" || exit 1

    # 2. install applications / cli tools
    bash "bin/install_packages.sh" "$@" || exit 1

}

main "$@"
