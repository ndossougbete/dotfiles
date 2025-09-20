dotfiles
========

1. Set up SSH keys

    ```
    ssh-keygen
    ```

2. Add it to https://github.com/ndossougbete

3. Grab and apply the dotfiles

  - Using `apt-get`

    ```
    sudo apt-get install curl vim meld terminator zsh python3
    curl -s https://github.com/ndossougbete/dotfiles/blob/master/setup.sh | sh
    ```

  - Using `dnf`

    ```
    sudo dnf install curl vim meld terminator zsh python3 fzf
    curl -s https://github.com/ndossougbete/dotfiles/blob/master/setup.sh | sh
    ```
