#alias ll="ls -laF"
#alias l="ls -F"
alias ls="ls -F"
alias upload="/Users/john/Documents/cf_dropbox/cf_drop.py"
alias v="vagrant"
alias test_pep8="git diff HEAD~1 --name-only | grep '\.py$' | xargs pep8 -r"
alias whatchanged="git diff --name-only master | grep -v test | xargs git diff master --"

# to saio VM
function rd {
    BN=`basename $PWD`
    echo "rsyncing $PWD to saio ($BN)"
    rsync --progress -a --delete   \
        --exclude go/bin           \
        --exclude guest_workspaces \
        --exclude=.tox             \
        --exclude=*egg-info        \
        --exclude=*egg             \
        --exclude=*eggs            \
        --exclude=.testrepository  \
        --exclude=*__pycache__*    \
        ./ swift@saio:$BN/
}

function rd_old {
    BN=`basename $PWD`
    exclude='--exclude=.git'
    excludemsg='(excluding .git)'
    if [[ $1 = "--with-git" ]]; then
        exclude=''
        excludemsg='(including .git)'
    fi
    echo "rsyncing $PWD to s.not.mn:$BN $excludemsg"
    rsync -a --delete --exclude=.tox $exclude --exclude=*egg-info --exclude=*egg ./ s.not.mn:$BN/
}

# to dev workstation
function rdev {
    BN=`basename $PWD`
    echo "rsyncing $PWD to dev box ($BN)"
    rsync --progress -a --delete   \
        --exclude go/bin           \
        --exclude guest_workspaces \
        --exclude=.tox             \
        --exclude=*egg-info        \
        --exclude=*egg             \
        --exclude=*eggs            \
        --exclude=.testrepository  \
        --exclude=*__pycache__*    \
        ./ john@dev:$BN/
}


# docs on colors: https://gist.github.com/thomd/7667642
export LESS="-XFEr"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegadabagacad
export PATH=~/bin:/usr/local/bin:/usr/local/opt/python/libexec/bin:/Library/Frameworks/Python.framework/Versions/2.6/bin:/usr/local/git/bin:$PATH
# export PATH="/usr/local/opt/python/libexec/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export EDITOR="/Users/john/bin/subl -nw"


BOLD="\[\033[1m\]"
NORMAL="\[\033[0m\]"

BLACK="\[\033[30m\]"
RED="\[\033[31m\]"
GREEN="\[\033[32m\]"
ORANGE="\[\033[33m\]"
BLUE="\[\033[34m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"
WHITE="\[\033[37m\]"

BLACK_BG="\[\033[40m\]"
RED_BG="\[\033[41m\]"
GREEN_BG="\[\033[42m\]"
ORANGE_BG="\[\033[43m\]"
BLUE_BG="\[\033[44m\]"
PURPLE_BG="\[\033[45m\]"
CYAN_BG="\[\033[46m\]"
WHITE_BG="\[\033[47m\]"

OFF="\[\033[00m\]"

GIT_REGEX='^## ([0-9A-Za-z/_-]+)(\.{3}([0-9A-Za-z/]+)( \[(ahead ([0-9]+)(, )?)?(behind ([0-9]+))?\])?)?(.* M [.0-9A-Za-z/]+)?(.*\?\? [.0-9A-Za-z/]+)?'

function parse_git_branch {
    current_branch_stats=`git status --porcelain -b 2>/dev/null`
    if [[ ! $? -eq 0 ]]; then
        return 0
    fi
    ahead=""
    behind=""
    up_arrow='⬆'
    down_arrow='⬇'
    untracked=""
    if [[ $current_branch_stats =~ $GIT_REGEX ]]; then
        # for i in {1..20}; do
        #     echo $i "${BASH_REMATCH[i]}"
        # done
        current_branch_name="${BASH_REMATCH[1]}"
        num_ahead="${BASH_REMATCH[6]}"
        num_behind="${BASH_REMATCH[9]}"
        if [[ ${num_ahead} != '' ]]; then
            ahead=" ${up_arrow}${num_ahead}"
        fi
        if [[ ${num_behind} != '' ]]; then
            behind=" ${down_arrow}${num_behind}"
        fi
        if [[ "${BASH_REMATCH[10]}" != "" ]]; then
            modified=true
        else
            modified=false
        fi
        if [[ "${BASH_REMATCH[11]}" != "" ]]; then
            untracked=true
        else
            untracked=false
        fi
        if [[ ${untracked} == true ]]; then
            if [[ ${modified} == true ]]; then
                echo "${BOLD}${RED}(${current_branch_name}${ahead}${behind})${OFF}"
            else
                echo "${BOLD}${WHITE}(${current_branch_name}${ahead}${behind})${OFF}"
            fi
        else
            if [[ ${modified} == true ]]; then
                echo "${NORMAL}${RED}(${current_branch_name}${ahead}${behind})${OFF}"
            else
                echo "${NORMAL}${GREEN}(${current_branch_name}${ahead}${behind})${OFF}"
            fi
        fi
    else
        return 0
    fi
}

function exitstatus {
    EXITSTATUS="$?"
    BASE="\u${BOLD}@\h${OFF}:${BLUE}${BOLD}\w${OFF}$(parse_git_branch)\$ "

    if [ "$EXITSTATUS" -eq "0" ]
    then
        PS1="${GREEN}${BASE}"
    else
        PS1="${RED}${BASE}"
    fi
    PS2="${BOLD}>${OFF} "
}

PROMPT_COMMAND=exitstatus

function _update_ps1() {
   export PS1="$(~/Documents/powerline-shell/powerline-shell.py --mode=patched $? 2> /dev/null)"
}

# export PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"

#export PYTHONSTARTUP=~/.pythonrc.py

export HISTSIZE=1500
#export HISTCONTROL=ignoredups
#shopt -s histappend
#export PROMPT_COMMAND="history -n; history -a"

# stuff for my cf_dropbox script
export DROPBOX_DOMAIN_NAME=d.not.mn

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


export HOMEBREW_NO_ANALYTICS=1

export GOROOT=/usr/local/opt/go
export PATH=$PATH:$GOROOT/bin



# `swift` auth options for saio
export ST_AUTH="http://192.168.56.2:8080/auth/v1.0"
export ST_USER="test:tester"
export ST_KEY="testing"


# bash completion (installed via brew)
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
