#!/bin/bash

sudo apt install grc -y;

echo "[+] Check your ~/.grc path and ensure it exists."

echo "[+] If it looks good, add this to a .bashrc type file"
echo ''
echo 'if hash grc &>/dev/null; then
  if [ -f "$HOME/.grc/grc.bashrc ]; then
    source "$HOME/.grc/grc.bashrc
  fi
fi'
echo ''
echo "[!] Add to ~/.config/fish/config.fish or in a new file in ~/.config/fish/conf.d/:"
echo "source /usr/local/etc/grc.fish"
echo ''
