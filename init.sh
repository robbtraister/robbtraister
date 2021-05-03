#!/bin/sh

# if no which, install debianutils for termux
[ $(which pwd 2> /dev/null) ] || pkg install debianutils

THIS_DIR=$(cd "$(dirname "$0")" && pwd)

# download apps
if [ "$(which open)" ]
then
  open \
    'https://www.google.com/search?btnI=I%27m+Feeling+Lucky&q=download+duet+display' \
    'https://www.google.com/search?btnI=I%27m+Feeling+Lucky&q=download+firefox+developer+edition'
fi

# install homebrew
if [ "$(which ruby)" ]
then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2> /dev/null
fi

# install common utilities
if [ "$(which brew)" ]
then
  brew install \
    bash \
    # bitwarden \ # use the app store version for biometrics
    # duet \ # use the beta version for wired connectivity
    homebrew/cask/docker \
    firefox \
    google-chrome \
    git \
    grep \
    gzip \
    iterm2 \
    mariadb \
    memcached \
    nano \
    nginx \
    node \
    nvm \
    openssh \
    openssl \
    postgresql \
    python2 \
    python3 \
    redis \
    ruby \
    tmux \
    vim \
    visual-studio-code \
    yarn \
    zoom \
    zsh
fi
if [ "$(which pkg)" ]
then
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
    python \
    python2 \
    redis \
    ruby \
    tmux \
    vim \
    yarn \
    zsh
fi

# install global npm utilities
if [ "$(which npm)" ]
then
  npm i -g \
    amphtml-validator \
    cost-of-modules \
    npm-check-updates \
    source-map-explorer \
    webpack-bundle-analyzer
fi

# setup vim
if [ "$(which vim)" ]
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

