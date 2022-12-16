eval "$(/opt/homebrew/bin/brew shellenv)"
export JULIA_NUM_THREADS=8
alias j="julia"
alias jp="julia --project"
alias jno="julia --startup-file=no"
alias ja="julia -i -e 'using Pkg; Pkg.activate(;temp=true)'"
alias js="code /Users/anand/.julia/config/startup.jl"
alias zprof="vim ~/.zprofile"
alias jd="cd ~/.julia/dev/"
alias la="ls -la"

jg () {
	jd 
	julia -e '
    jg()
	' $1
}

