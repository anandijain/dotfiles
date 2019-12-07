# Easy way to extract archives
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1;;
           *.tar.gz)    tar xvzf $1;;
           *.bz2)       bunzip2 $1 ;;
           *.rar)       unrar x $1 ;;
           *.gz)        gunzip $1  ;;
           *.tar)       tar xvf $1 ;;
           *.tbz2)      tar xvjf $1;;
           *.tgz)       tar xvzf $1;;
           *.zip)       unzip $1   ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1;;
           *) echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
}


# Move 'up' so many directories instead of using several cd ../../, etc.
up() { cd $(eval printf '../'%.0s {1..$1}) && pwd; }


function commit() {
    # add and commit all 
    git add .
    git commit -a -m "$1"
}


function lazygit() {
    # add commit and push all
    git add .
    git commit -a -m "$1"
    git push
}

function swap_pull_swap(){
	git checkout "$1"
	git pull
	git branch "$2"
	git checkout "$2"
}

function clean_branches(){
	git branch -d $(git branch --merged=master | grep -v master)
	git fetch --prune
}

function micro_la(){
	gcloud beta compute --project "absa-242603" ssh --zone "us-west2-a" "micro-la"
}

function micro_lon(){
	gcloud beta compute --project "absa-242603" ssh --zone "europe-west2-c" "micro-lon"
}

alias jl='julia'
alias py='python'
alias pip='pip3.6'
alias chrome='google-chrome'
alias blender='/home/sippycups/Downloads/Applications/blender-2.80-linux-glibc217-x86_64/blender'
alias unity='/home/sippycups/Programming/Unity/UnityHubSetup.AppImage'
alias tor='~/learning/bash/open_tor.sh'
alias h='history'

# Git related
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gd='git diff'
alias gb='git branch'
alias gl='git log'
alias gsb='git show-branch'
alias gco='git checkout'
alias lg='lazygit'
alias cmt='commit'
alias cleen='clean_branches'
alias swap='swap_pull_swap'

# Add color in manpages for less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/programming/go
alias lean='/home/sippycups/Downloads/langs/lean-3.4.2-linux/bin/lean'
