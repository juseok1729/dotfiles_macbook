#!/bin/bash

. "bin/utils.sh"


install_neovim_plugin() {

    if [[ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]]; then

        execute \
            "curl -fLo \
            ~/.local/share/nvim/site/autoload/plug.vim \
            --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" \
            "Neovim Plugin"

        nvim +PlugInstall +qall!

    fi

}

install_python_package() {

    execute \
        "python3 -m pip install pynvim &> /dev/null" \
        "pynvim"

    execute \
        "python3 -m pip install python-language-server &> /dev/null" \
        "python language server"

}

install_jupyterlab() {

    execute \
        "python3 -m pip install jupyterlab &> /dev/null" \
        "jupyter lab"

    execute \
        "python3 -m pip install jupyter-archive &> /dev/null" \
        "jupyter archive"

    execute \
        "jupyter labextension install @arbennett/base16-mexico-light &> /dev/null" \
        "jupyter theme"

    execute \
        "git clone https://github.com/lckr/jupyterlab-variableInspector &> /dev/null \
         && cd jupyterlab-variableInspector \
         && npm install \
         && npm run build \
         && jupyter labextension install . --no-build \
         && cd .. \
         && rm -rf jupyterlab-variableInspector" \
        "jupyter variable-inspector"

    execute \
        "git clone https://github.com/jupyterlab/jupyterlab-mp4 &> /dev/null \
         && cd jupyterlab-mp4 \
         && npm install \
         && npm run build \
         && jupyter labextension install . --no-build \
         && cd .. \
         && rm -rf jupyterlab-mp4" \
        "jupyter mp4"

}


main() {

    print_in_blue "\n • Install applications and cli tools\n\n"

    # run os-specific scripts
    bash bin/install_packages_$(get_os).sh "$@"

    install_neovim_plugin

    install_python_package

    install_jupyterlab

}

main "$@"
