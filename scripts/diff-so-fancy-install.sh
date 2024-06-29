# tired of "Unable to locate package diff-so-fancy ?"
# choose a folder that is in your PATH or create a new one
mkdir -p ~/.local/bin 
# add ~/.local/bin to your PATH (.bashrc or .zshrc)
cd ~/.local/bin
git clone https://github.com/so-fancy/diff-so-fancy diffsofancy
chmod +x diffsofancy/diff-so-fancy
ln -s ~/.local/bin/diffsofancy/diff-so-fancy ~/.local/bin/diff-so-fancy
