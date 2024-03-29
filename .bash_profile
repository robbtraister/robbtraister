export BASH_SILENCE_DEPRECATION_WARNING=1
export HISTSIZE=5000
export HISTFILESIZE=10000

export AWS_REGION=us-east-1

export PS1="\[\e[1;33m\]\w\[\e[1;32m\]\$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/^/{/' -e 's/$/}/')\n\[\e[1;36m\][\$(date +%k:%M:%S)]\[\e[0m\]: "
# export PS1="\$(echo \$WORKSPACE | sed -e 's/^/\[\033[38;5;208m\][/' -e 's/$/]\[\033[0m\]/')\[\e[1;33m\]\w\[\e[1;32m\]\$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/^/{/' -e 's/$/}/')\n\[\e[1;36m\][\$(date +%k:%M:%S)]\[\e[0m\]: "
# export PS1="\[\e[43m\]\[\e[38;5;0m\]\w\[\e[42m\]\[\e[1;97m\]\$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/^/{/' -e 's/$/}/')\n\[\e[0m\]\[\e[1;36m\][\$(date +%k:%M:%S)]\[\e[0m\]: "

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

[ ! -f /opt/homebrew/bin/brew ] || eval "$(/opt/homebrew/bin/brew shellenv)"

shopt -s globstar

# git shortcuts
alias add='git add -A'
alias amend='git commit --amend'
alias branches='git branch --all'
alias cb='git checkout -b'
alias clean='git add -A && git reset HEAD --hard'
alias co='git checkout'
# alias commit='git commit -m'
alias d='git diff -b'
alias dh='git diff -b HEAD~1..HEAD'
alias drop='git stash drop'
alias list='git stash list'
alias locals='git branch --list'
alias log='git log'
alias pop='git add -A && git stash pop'
alias pull='git pull && prune'
alias push="git push -u origin \$(git rev-parse --abbrev-ref HEAD) --force-with-lease && git push --tags --no-verify"
alias stash='git stash push --keep-index --include-untracked && git reset HEAD'
alias status='git status'
alias wip='git commit -m wip --no-verify'

commit() {
  if [ $# == 0 ]
  then
    git commit
  else
    git commit -m "$1"
  fi
}

fixup() {
  COMMIT=${1}
  if [ -z "${COMMIT}" ]
  then
    >&2 echo 'commit hash is required'
    exit 1
  fi

  git commit --fixup ${COMMIT}
  git rebase -i --autosquash ${COMMIT}~
}

prune() {
  REMOTE=${1:-origin}
  BRANCHES=$(git remote prune "${REMOTE}" | awk '/^ \* \[pruned\]/{ print $3; }' | sed "s/${REMOTE}\///")
  for BRANCH in ${BRANCHES}
  do
    git branch -D "${BRANCH}" 2> /dev/null
  done
}

remotes() {
  if [ "$1" ]
  then
    git for-each-ref --format='%(refname:strip=2)' "refs/remotes/$1"
  else
    git branch --remotes
  fi
}

reset() {
  REF=${1:-HEAD}
  if [ -n "$(echo ${REF} | grep '^[0-9]*$')" ]
  then
    REF="HEAD~${REF}"
  fi
  git reset "${REF}"
}

show() {
  ref=${1:-'0'}

  if [ -n "$(echo "$ref" | egrep -x '\d+')" ]
  then
    ref="stash@{${ref}}"
  fi

  git stash show "${ref}"
}

# docker shortcuts
alias dc='docker compose'
alias images='docker images'
alias nuke="docker system prune -f && docker network prune -f && (docker volume ls --format='{{.Name}}' | egrep '^[a-z0-9]{64}$' | xargs docker volume rm)"
# alias run='npm run-script'

build() {
  dc build --pull $@
}
up() {
  dc up --build --remove-orphans --force-recreate $@
}
down() {
  dc down -v $@
}
bud() {
  dc build --pull $@ && dc up --remove-orphans --force-recreate $@; dc down -v
}

# python shortcuts
alias pip=pip3
alias python=python3
alias b64d='python3 -c "import base64, sys; print(str(base64.b64decode(bytes(sys.argv[1], \"utf-8\")), \"utf-8\"));"'
alias b64e='python3 -c "import base64, sys; print(str(base64.b64encode(bytes(sys.argv[1], \"utf-8\")), \"utf-8\"));"'
alias serve='python3 -m http.server'

# random shortcuts
alias amp='amphtml-validator'
alias com='cost-of-modules'
alias etime='ps -o etime'
alias sme='source-map-explorer'
alias wba='webpack-bundle-analyzer'
alias y='yarn'

presetDir() {
  cd "$1/$2"
}
alias ws="presetDir $HOME/Documents/workspace"
alias ci="presetDir $HOME/Documents/workspace/CitrineInformatics"
alias rt="presetDir $HOME/Documents/workspace/robbtraister"
alias sb="presetDir $HOME/Documents/workspace/sandbox"
alias sm="presetDir $HOME/Documents/workspace/SaasLinkHQ"
# if no package.json is found, npm prefix returns pwd
alias root="cd $(npm prefix)"

stop() {
  NAME="$1"
  if [ "$NAME" ]
  then
    IDS=$(docker ps --format '{{.ID}}' --filter name=$NAME)
  else
    IDS=$(docker ps --format '{{.ID}}')
  fi
  docker stop $IDS 2> /dev/null
}

dev() {
  if [ "$(command -v tmux)" ]
  then
    DIR_NAME="$(basename "$(pwd)")"
    if [ -z "$(tmux ls 2> /dev/null | grep "^${DIR_NAME}: ")" ]
    then
      tmux new-session -d -s "${DIR_NAME}" -n 'dev'
      HEIGHT=$(tput lines)
      WIDTH=$(tput cols)
      if [ "$(expr ${HEIGHT} \* 3)" -gt "${WIDTH}" ]
      then
        tmux split-pane -v -b 'npm run dev'
        tmux split-pane -v -t 0 'npm run test -- --watch'
        tmux select-pane -t 2
      else
        tmux split-pane -h 'npm run dev'
        tmux split-pane -v -t 1 'npm run test -- --watch'
        tmux select-pane -t 0
      fi
    fi
    tmux attach-session -t "${DIR_NAME}"
  else
    npm run dev
  fi
}

gr() {
  flags='-r'
  if [ $CASE_INSENSITIVE ]
  then
    flags='-ri'
  fi
  grep "$flags" "$1" '.' --exclude=.git* --exclude=package-lock.json --exclude-dir={.git,.yarn,bower_components,build,coverage,dist,node_modules} --exclude=.*cache --exclude=*.tsbuildinfo
}
alias gri='CASE_INSENSITIVE=true gr'

ip() {
  ifconfig | awk '/broadcast/ { print $2 }'
}

mkcd() {
  mkdir -p "$1"
  cd "$1"
}

bump() {
  (
    cd $(npm prefix)
    YARN=$([ -f yarn.lock ] && echo 'yarn')
    rm -rf package-lock.json yarn.lock node_modules/
    ncu -u
    if [ $YARN ]
    then
      yarn install
    else
      npm i
    fi
  )
}

if [ "$(command -v fnm)" ]
then
  eval "$(fnm env)"
  alias nvm=fnm
fi

update() {
  if [ "$(command -v softwareupdate)" ]
  then
    softwareupdate -i -a
  fi

  if [ "$(command -v xcode-select)" ]
  then
    xcode-select --install 2> /dev/null
  fi

  if [ "$(command -v brew)" ]
  then
    brew update-reset
    brew update
    brew upgrade --greedy
    brew cleanup
    brew doctor
  fi

  if [ "$(command -v pkg)" ]
  then
    pkg update -y
  fi

  if [ "$(command -v apt)" ]
  then
    apt update
    apt upgrade -y
    apt autoremove
  fi

  if [ "$(nvm --version 2> /dev/null)" ]
  then
    CURRENT=$(nvm current)
    nvm use system
  fi
  if [ "$(command -v ncu)" ]
  then
    $(ncu -g | grep '^npm -g install')
  fi
  npm -g update
  if [ "$(nvm --version 2> /dev/null)" ]
  then
    nvm use "${CURRENT}"
  fi

  (
    rt
    cd robbtraister
    pull
  )
}

[ -z "$EDITOR" ] && export EDITOR=vim
[ -z "$GIT_EDITOR" ] && export GIT_EDITOR=vim

# [ -s /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# # [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || {
#     # if not found in /usr/local/etc, try the brew --prefix location
#     [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
#         . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
# # }

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ "$(nvm --version 2> /dev/null)" ]
then
  nvm_use() {
    if [ -f ./package.json ]
    then
      (
        while [ true ]
        do
          if [ -f ./.nvmrc ]
          then
            nvm use
            exit 0
          fi

          if [ "$(pwd)" == '/' ]
          then
            # no .nvmrc file found, so use default
            exit 1
          else
            builtin cd ..
          fi
        done
      ) || nvm use default
    fi
  }

  cd() {
    builtin cd "$@" && nvm_use
  }

  nvm_use
fi

# source <(npx --shell-auto-fallback bash)

function iterm2_print_user_vars() {
  iterm2_set_user_var badge "$(basename "$(pwd)")\n$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/^/{/' -e 's/$/}/')"
}

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH="/usr/local/sbin:$PATH"

vscode=$(which code)
code() {
  (
    cd ${1:-.}
    $vscode .
  )
}
