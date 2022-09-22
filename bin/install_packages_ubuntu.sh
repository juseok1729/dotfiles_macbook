#!/bin/bash

. "bin/utils.sh"

add_key() {

    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

}

add_ppa() {
    sudo add-apt-repository -y ppa:"$1" &> /dev/null
}

add_to_source_list() {
    sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'"
}

autoremove() {

    execute \
        "sudo apt-get autoremove -qqy" \
        "APT (autoremove)"

}

install_package() {

    declare -r PACKAGE_READABLE_NAME="$1"
    declare -r PACKAGE="$2"
    declare -r EXTRA_ARGUMENTS="$3"

    if ! package_is_installed "$PACKAGE"; then
        execute \
            "sudo apt-get install \
            --no-install-recommends \
            --allow-unauthenticated \
            -qqy \
            $EXTRA_ARGUMENTS $PACKAGE" "$PACKAGE_READABLE_NAME"

    else

        print_success "$PACKAGE_READABLE_NAME"

    fi

}

package_is_installed() {
    dpkg -s "$1" &> /dev/null
}

update() {

    # Resynchronize the package index files from their sources.

    execute \
        "sudo apt-get update -qqy" \
        "APT (update)"

}

upgrade() {

    # Install the newest versions of all packages installed.

    execute \
        "export DEBIAN_FRONTEND=\"noninteractive\" \
            && sudo apt-get -o Dpkg::Options::=\"--force-confnew\" upgrade -qqy" \
        "APT (upgrade)"

}

add_ppa_nodejs() {

    curl -sfL https://deb.nodesource.com/setup_16.x | sudo -E bash - &> /dev/null

}


main() {

    update

    install_package "Software Properties Common" "software-properties-common"

    install_package "Git" "git"

    install_package "Bash" "bash"

    install_package "Tmux" "tmux"

    install_package "Curl" "curl"

    install_package "Tree" "tree"

    install_package "Vifm" "vifm"

    install_package "clangd-9" "clangd-9"

    install_package "DNS utils" "dnsutils"

    add_ppa "neovim-ppa/stable"

    update

    install_package "Neovim" "neovim"

    upgrade

    autoremove

    add_ppa_nodejs

    update

    install_package "Nodejs" "nodejs"

    sudo npm install -g typescript

}

main
