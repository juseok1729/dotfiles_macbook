#!/bin/bash

. "bin/utils.sh"


create_gitconfig_private() {

    declare -r FILE_PATH="$HOME/.gitconfig.private"

    if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then

        printf "%s\n" \
"[commit]

    # Sign commits using GPG.
    # https://help.github.com/articles/signing-commits-using-gpg/

    # gpgsign = true


[user]

    name =
    email =
    # signingkey =" \
        >> "$FILE_PATH"

    fi

    print_result $? "$FILE_PATH"

}

create_bashrc_private() {

    touch $HOME/.bashrc.private

}


main() {

    print_in_blue "\n • Setup configurations\n\n"

    # run os-specific scripts
    bash bin/symlink_configs_$(get_os).sh "$@"

    # create private gitconfig
    create_gitconfig_private

    # create private bashrc
    create_bashrc_private

}

main "$@"
