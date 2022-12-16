expect -c 'spawn bash -c "curl -fsSL https://install.julialang.org | sh"; expect "Proceed"; send -- "\r"; expect eof'
mkdir -p ~/.julia/config/
ln -s ~/dotfiles/startup.jl ~/.julia/config/startup.jl
ln -s ~/dotfiles/.zprofile ~/.zprofile
