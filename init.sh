#!/bin/sh

# if no which, install debianutils for termux
[ $(command -v pwd 2> /dev/null) ] || pkg install debianutils

THIS_DIR=$(cd "$(dirname "$0")" && pwd)

if [ "$(command -v apt)" ]
then
  apt update
  apt upgrade
fi

if [ "$(command -v pkg)" ]
then
  pkg update
  pkg install \
    git \
    grep \
    gzip \
    man \
    make \
    mariadb \
    memcached \
    nano \
    nginx \
    nodejs \
    openssh \
    openssl \
    postgresql \
    python3 \
    redis \
    ruby \
    tmux \
    vim \
    yarn \
    zsh
fi

# install homebrew
if [ "$(command -v ruby)" ]
then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2> /dev/null
fi

# install common utilities
if [ "$(command -v brew)" ]
then
  brew tap homebrew/core
  brew tap homebrew/cask-versions
  brew tap hashicorp/tap
  brew tap oven-sh/bun
  brew install \
    arc \
    authy \
    bash \
    oven-sh/bun/bun \
    caffeine \
    calibre \
    db-browser-for-sqlite \
    discord \
    duet \
    homebrew/cask/docker \
    firefox-developer-edition \
    fnm \
    gimp \
    git \
    github \
    google-chrome \
    grep \
    gzip \
    iterm2 \
    jq \
    kap \
    keybase \
    macdown \
    mariadb \
    mas \
    memcached \
    nano \
    nginx \
    node \
    openssh \
    openssl \
    pgadmin4 \
    postgresql \
    python3 \
    redis \
    ruby \
    slack \
    hashicorp/tap/terraform \
    tmux \
    vim \
    visual-studio-code \
    yarn \
    zoom \
    zsh

  # Use the App Store version of BitWarden for biometrics support
  mas install 1352778147 # bitwarden
fi

# install global npm utilities
if [ "$(command -v npm)" ]
then
  npm i -g \
    # amphtml-validator \
    cost-of-modules \
    npm-check-updates
    # source-map-explorer \
    # webpack-bundle-analyzer
fi

# setup vim
if [ "$(command -v vim)" ]
then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  cat < "${THIS_DIR}/.vimrc" > ~/.vimrc

  # install vim plugins
  vim -c ':PlugInstall'
fi

# setup bash_profile
PROFILE_IMPORT=". ${THIS_DIR}/.bash_profile"
touch ~/.bash_profile
if [ ! "$(cat ~/.bash_profile | grep -F "${PROFILE_IMPORT}")" ]
then
  echo "\n${PROFILE_IMPORT}" >> ~/.bash_profile
fi
