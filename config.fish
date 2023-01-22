fish_add_path "/Users/anand/.juliaup/bin"
if status is-interactive
    # Commands to run in interactive sessions can go here
end
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
