#!/bin/bash

. "bin/utils.sh"


main() {

    declare -A FILES_TO_SYMLINK=(
        ["tmux.conf"]="$HOME/.tmux.conf"
        ["gitconfig"]="$HOME/.gitconfig"
        ["bashrc"]="$HOME/.bashrc"
        ["bash_profile"]="$HOME/.bash_profile"
        ["hushlogin"]="$HOME/.hushlogin"
        ["init.vim"]="$HOME/.config/nvim/init.vim"
        ["yabairc"]="$HOME/.yabairc"
        ["skhdrc"]="$HOME/.skhdrc"
        ["vifmrc"]="$HOME/.config/vifm/vifmrc"
        ["karabiner.json"]="$HOME/.config/karabiner/karabiner.json"
        ["alacritty.yml"]="$HOME/.config/alacritty/alacritty.yml"
    )

    local i=""
    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    skip_questions "$@" && skipQuestions=true

    for i in "${!FILES_TO_SYMLINK[@]}"; do

        sourceFile="$(pwd)/conf/$i"

        targetFile="${FILES_TO_SYMLINK[$i]}"

        create_symlinks $sourceFile $targetFile $skipQuestions

    done

}

main "$@"
