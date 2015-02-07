#!/usr/bin/env bash
#
# bash -c "$(curl -fsSL https://raw.github.com/dennisjlee/bootstrap_dotfiles/master/bootstrap_dotfiles.sh)"
#
#
# Aptitude packages:
# autojump - fast directory navigation
# build-essential - for GCC, GNU Make, etc.
# curl - obviously
# exuberant-ctags - for Vim Tagbar
# git - obviously
# tmux - terminal multiplexer
# vim-nox - Vim compiled with support for scripting with Perl, Python, Ruby, and Tcl
#
#
# Homebrew packages:
# 
#
#
# Pip packges:
# ipython -
# virtualenv -


aptitude="aptitude"
squeezePkgs="build-essential curl exuberant-ctags git htop screen tmux vim-nox"
precisePkgs="autojump build-essential curl exuberant-ctags git htop screen tmux vim-nox"
trustyPkgs="autojump build-essential curl exuberant-ctags git htop screen tmux vim-nox"
saucyPkgs="autojump build-essential curl exuberant-ctags git htop screen tmux vim-nox"
brews="ack autojump cmake ctags ifstat libevent netcat wget htop screen node mongodb python"
pipPkgs="ipython virtualenv"


scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function cecho() {
    case "${2}" in
        red) code=31;;
        green) code=32;;
        yellow) code=33;;
        blue) code=34;;
        purple) code=35;;
        cyan) code=36;;
        white) code=37;;
        *) code=1;;
    esac
    printf "\n\e[0;${code}m${1}\e[0m\n"
}


function notify() {
    cecho "${1}" cyan
    sleep 1
}


function ask() {
    cecho "${1}" yellow
}


function pause() {
    read -p "$*"
}


function error() {
    cecho "${1}" red
    sleep 1
}


function die() {
    cecho "Error: ${1}" red
    exit 1
}


function backup() {
    for arg in "$@"; do
        if [ -e ${arg} -o -h ${arg} ]; then
            notify "Backing up existing ${arg} to ${arg}.bak"
            rm -fr ${arg}.bak && mv ${arg} ${arg}.bak
        fi
        sleep 1
    done
}


function askYesNo() {
    ask "Do you want to ${1} ${2}?"
    select ynq in "yes" "no" "quit"; do
        case ${ynq} in
            yes) shouldInstall=true; break;;
            no) shouldInstall=false; break;;
            quit) exit;;
        esac
    done
}


function aptInstall() {
    case "${1}" in
        trusty) aptPkgs="${trustyPkgs}";;
        precise) aptPkgs="${precisePkgs}";;
        squeeze) aptPkgs="${squeezePkgs}";;
        saucy) aptPkgs="${saucyPkgs}";;
        *) ;;
    esac

    askYesNo "install" "aptitude packages: ${aptPkgs}"
    if ${shouldInstall}; then
        ask "We'll need your password:"
        sudo add-apt-repository ppa:git-core/ppa
        sudo ${aptitude} install ${aptPkgs}
    fi
}


function installHomebrew() {
    if [ ! -x /usr/local/bin/brew ]; then
        askYesNo "install" "Homebrew"
        if ${shouldInstall}; then
            printf "\n"
            printf "\e[0;32m"'    __  __                     __                     '"\e[0m\n"
            printf "\e[0;32m"'   / / / /___  ____ ___  ___  / /_  ________ _      __'"\e[0m\n"
            printf "\e[0;32m"'  / /_/ / __ \/ __ `__ \/ _ \/ __ \/ ___/ _ \ | /| / /'"\e[0m\n"
            printf "\e[0;32m"' / __  / /_/ / / / / / /  __/ /_/ / /  /  __/ |/ |/ / '"\e[0m\n"
            printf "\e[0;32m"'/_/ /_/\____/_/ /_/ /_/\___/_.___/_/   \___/|__/|__/  '"\e[0m\n\n"

            notify "Installing Homebrew"
            ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
        fi
    else
        notify "Updating Homebrew and formulae"
        brew update
    fi
}


function installBrews() {
    if brewLoc="$(which brew)" && [ ! -z "${brewLoc}" ]; then
        installedBrews=$(brew list)
        missingBrews=""

        # Create string of missing Homebrew formulae
        for formula in ${brews}; do
            test "${installedBrews#*$formula}" == "${installedBrews}" && missingBrews="${missingBrews} ${formula}"
        done

        if [ ! "${missingBrews}" == "" ]; then
            askYesNo "install" "Homebrew packages: ${missingBrews}"
            if ${shouldInstall}; then
                brew install ${missingBrews}
            fi
        fi
    else
        error "${brewLoc} is not executable"
    fi
}

function configureDotfiles() {
    askYesNo "configure" "dotfiles"
    if ${shouldInstall}; then

        printf "\n"
        printf "[0;32m"'      _       _    __ _ _           '"[0m\n"
        printf "[0;32m"'   __| | ___ | |_ / _(_) | ___  ___ '"[0m\n"
        printf "[0;32m"'  / _` |/ _ \| __| |_| | |/ _ \/ __|'"[0m\n"
        printf "[0;32m"' | (_| | (_) | |_|  _| | |  __/\__ \'"[0m\n"
        printf "[0;32m"'  \__,_|\___/ \__|_| |_|_|\___||___/'"[0m\n"

        cd ${HOME}
        export GIT_DIR=${HOME}/dotfiles.git
        export GIT_WORK_TREE=${HOME}
        git init
        git config branch.master.rebase true
        # Note: readonly pull URL and writable push URL so it doesn't die if I
        # don't have my SSH keys set up right
        git remote add origin git://github.com/dennisjlee/dotfiles.git
        git remote set-url origin --push git@github.com:dennisjlee/dotfiles.git
        git fetch
        git reset --hard origin/master
        git branch --set-upstream master origin/master
        git submodule update --init --recursive
        unset GIT_DIR
        unset GIT_WORK_TREE
    fi
}

function configureGit() {
    askYesNo "configure" "git"
    if ${shouldInstall}; then
        printf "\n"
        printf "\e[0;32m"'        _ _   '"\e[0m\n"
        printf "\e[0;32m"'       (_) |  '"\e[0m\n"
        printf "\e[0;32m"'   __ _ _| |_ '"\e[0m\n"
        printf "\e[0;32m"'  / _` | | __|'"\e[0m\n"
        printf "\e[0;32m"' | (_| | | |_ '"\e[0m\n"
        printf "\e[0;32m"'  \__, |_|\__|'"\e[0m\n"
        printf "\e[0;32m"'   __/ |      '"\e[0m\n"
        printf "\e[0;32m"'  |___/       '"\e[0m\n\n"

        ask "Setting up git config\nWhat's your name?"
        read git_name
        git config --global user.name "${git_name}"
        ask "What's your email?"
        read git_email
        git config --global user.email "${git_email}"
        git config --list
        pause "Here's your global git config. You can edit this later anytime. Press [Enter] key to continue."
    fi
}

function installPipPkgs() {
    askYesNo "install" "pip packages: ${pipPkgs}"
    if ${shouldInstall}; then
        if pipLoc="$(which pip)" && [ ! -z "${pipLoc}" ]; then
            notify "Installing pip packages: ${pipPkgs}"
            sudo pip install ${pipPkgs}
        fi
    fi
}



# Debian-based distributions
if [ -e /usr/bin/lsb_release ]; then
    distro=$(/usr/bin/lsb_release --codename --short)

    if [ "${distro}" != "trusty" -a "${distro}" != "precise" -a "${distro}" != "squeeze" -a "${distro}" != "saucy" ]; then
        die "unsupported distribution: ${distro}"
    fi

    aptInstall "${distro}"
fi;


# Mac OS X
[ "$(uname -s)" == "Darwin" ] && installHomebrew && installBrews


configureDotfiles
configureGit
installPipPkgs
# TODO rvm
# source ~/.rvm/scripts/rvm see http://stackoverflow.com/a/11105199/553994
