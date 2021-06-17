dotfiles
========

```
git clone git@github.com:ndossougbete/dotfiles.git
cd dotfiles

ln -s  $(pwd)/gitconfig ~/.gitconfig

echo "source $(pwd)/zshrc" > ~/.zshrc
echo "source $(pwd)/zshrc.home" >> ~/.zshrc

mkdir -p ~/.local/lib/antigen
sh -c 'echo "From https://github.com/zsh-users/antigen" > ~/.local/lib/antigen/README' 
curl -L git.io/antigen > ~/.local/lib/antigen/antigen.zsh

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ~/.local/lib/depot_tools

which zsh
echo "Enter zsh binary path to change shell for the current user"
chsh
```
