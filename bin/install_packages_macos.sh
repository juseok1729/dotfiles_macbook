#!/bin/bash

. "bin/utils.sh"


are_xcode_command_line_tools_installed() {
    xcode-select --print-path &> /dev/null
}

install_xcode_command_line_tools() {

    # If necessary, prompt user to install
    # the `Xcode Command Line Tools`.

    xcode-select --install &> /dev/null

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait until the `Xcode Command Line Tools` are installed.

    execute \
        "until are_xcode_command_line_tools_installed; do \
            sleep 5; \
         done" \
        "Xcode Command Line Tools"

}

install_fake_xcode() {

    sudo touch /Applications/Xcode.App

}

brew_install() {

    declare -r FORMULA_READABLE_NAME="$1"
    declare -r FORMULA="$2"
    declare -r ARGUMENTS="$3"
    declare -r TAP_VALUE="$4"

    # Check if `Homebrew` is installed.
    if ! cmd_exists "brew"; then
        print_error "$FORMULA_READABLE_NAME ('Homebrew' is not installed)"
        return 1
    fi

    # If `brew tap` needs to be executed,
    # check if it executed correctly.
    if [ -n "$TAP_VALUE" ]; then
        if ! brew_tap "$TAP_VALUE"; then
            print_error "$FORMULA_READABLE_NAME ('brew tap $TAP_VALUE' failed)"
            return 1
        fi
    fi

    # Install the specified formula.
    if brew list "$FORMULA" &> /dev/null; then
        print_success "$FORMULA_READABLE_NAME"
    else
        execute \
            "brew install $FORMULA $ARGUMENTS" \
            "$FORMULA_READABLE_NAME"
    fi

}

brew_tap() {
    brew tap "$1" &> /dev/null
}

brew_update() {

    execute \
        "brew update" \
        "Homebrew (update)"

}

brew_upgrade() {

    execute \
        "brew upgrade" \
        "Homebrew (upgrade)"

}


brew_prefix() {

    local path=""

    if path="$(brew --prefix 2> /dev/null)"; then
        printf "%s" "$path"
        return 0
    else
        print_error "Homebrew (get prefix)"
        return 1
    fi

}

install_homebrew() {

    if ! cmd_exists "brew"; then
        ask_for_sudo
        printf "\n" \
            | /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
            &> /dev/null
              #  └─ simulate the ENTER keypress
    fi

    print_result $? "Homebrew"
}

build_limelight() {

    local tmpFile=""

    tmpFile="$(mktemp -d /tmp/XXXXX)"

    cd $tmpFile \
        && git clone --quiet "https://github.com/koekeishiya/limelight" \
        && cd limelight \
        && make &> /dev/null \
        && mv bin/limelight /usr/local/bin/limelight

    rm -rf $tmpFile

}

change_default_bash() {

    local newShellPath=""

    local brewPrefix=""

    brewPrefix="$(brew_prefix)" || return 1

    newShellPath="$brewPrefix/bin/bash"

    if ! grep "$newShellPath" < /etc/shells &> /dev/null; then
        execute \
            "printf '%s\n' '$newShellPath' | sudo tee -a /etc/shells" \
            "Bash (add '$newShellPath' in '/etc/shells')" \
        || return 1
    fi

    sudo chsh -s "$newShellPath" &> /dev/null

    print_result $? "Bash (use latest version)"

}

main() {

    install_xcode_command_line_tools

    install_fake_xcode

    install_homebrew

    brew_update

    brew_upgrade

    brew_install "Bash" "bash" && change_default_bash

    brew_install "Bash Completion 2" "bash-completion@2"

    brew_install "Chrome" "google-chrome" "--cask"

    brew_install "Firefox" "firefox" "--cask"

    brew_install "Iosevka" "font-iosevka" "--cask" "homebrew/cask-fonts"

    brew_install "IBM Plex" "font-ibm-plex"

    brew_install "Git" "git"

    brew_install "GitHub CLI" "github/gh/gh"

    brew_install "GPG" "gpg"

    brew_install "Pinentry" "pinentry-mac"

    brew_install "Karabiner" "karabiner-elements" "--cask"

    brew_install "Flotato" "flotato" "--cask"

    brew_install "Slack" "slack" "--cask"

    brew_install "Notion" "notion" "--cask"

    brew_install "Yabai" "koekeishiya/formulae/yabai"

    brew_install "Skhd" "koekeishiya/formulae/skhd"

    brew_install "Tmux" "tmux"

    brew_install "Tmux (pasteboard)" "reattach-to-user-namespace"

    brew_install "VLC" "vlc" "--cask"

    brew_install "FFmpeg" "ffmpeg"

    brew_install "Neovim" "neovim"

    brew_install "Vifm" "vifm"

    brew_install "Vifm" "vifm"

    brew_install "Alacritty" "alacritty" "--cask"

    build_limelight

    change_default_bash
}

main "$@"
