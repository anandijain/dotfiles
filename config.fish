fish_add_path "/Users/anand/.juliaup/bin"
fish_add_path "/opt/homebrew/bin/"
fish_add_path "/Users/anand/.cargo/bin/"
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
alias pip="pip3.10"
alias python="python3.10"
alias e="nvim"
alias matlab="/Applications/MATLAB_R2022b.app/bin/matlab -nosplash -nodesktop"

