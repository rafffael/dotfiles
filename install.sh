#!/usr/bin/env bash

#             __  __  __            _
#  _ __ __ _ / _|/ _|/ _| __ _  ___| |
# | '__/ _` | |_| |_| |_ / _` |/ _ \ |
# | | | (_| |  _|  _|  _| (_| |  __/ |
# |_|  \__,_|_| |_| |_|  \__,_|\___|_|
#

set -e

DOTFILES=${DOTFILES:-~/.dotfiles}
REPO=${REPO:-rafffael/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

check_bin() {
  command -v "$@" >/dev/null 2>&1 || {
    echo >&2 "\"$@\" is not installed. Aborting."; exit 1;
  }
}

create_link() {
  base=".$(basename $1)"
  dotfile="${base%.symlink}"
  dotfilepath="$HOME/$dotfile"

  # existant dotfile is not a symlink
  if [[ ! -L $dotfilepath ]]
    then
    echo " Creating symlink for '$dotfile' "
    cd $HOME && ln --backup=simple -s $1 $dotfilepath || exit 1;
  fi
}

prepare_repo() {
  check_bin vim
  check_bin curl
  check_bin git

  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$DOTFILES" || {
    echo "git clone failed"
    exit 1
  }

  curl -fLo ${DOTFILES}/vim/vim.symlink/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

setup_dots() {
  prepare_repo

  find $DOTFILES -not -path '*/\.git/*' -name '*.symlink' | \
  while read f
    do
      create_link "$f"
    done
}

main() {
  setup_dots
}

main "$@"

