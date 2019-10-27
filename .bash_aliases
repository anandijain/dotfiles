function commit() {
    git add .
    git commit -a -m "$1"
}


function lazygit() {
    git add .
    git commit -a -m "$1"
    git push
}


alias gs='git status'
alias gd='git diff'
alias gb='git branch'

alias lg='lazygit'
alias cmt='commit'

alias h='history'
