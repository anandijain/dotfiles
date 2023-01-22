eval "$(/opt/homebrew/bin/brew shellenv)"
export JULIA_NUM_THREADS=8
alias j="julia"
alias jp="julia --project"
alias jno="julia --startup-file=no"
alias ja="julia -i -e 'using Pkg; Pkg.activate(;temp=true)'"
alias js="code /Users/anand/.julia/config/startup.jl"
alias zprof="code ~/.zprofile"
alias jd="cd ~/.julia/dev/"
alias jdbg="JULIA_DEBUG=loading julia --startup=no --project"
alias ju="juliaup"

alias la="ls -la"

alias matlab="/Applications/MATLAB_R2022b.app/bin/matlab -nosplash -nodesktop"
export JL_MATLAB_PATH="/Applications/MATLAB_R2022b.app/bin/matlab"
jg () {
	jd 
	julia -e '
    jg()
	' $1
}

