# VimSetup
```
./wrapper.sh
```
(Don't use the following)
```
sudo apt-get install fonts-powerline
git clone https://github.com/snehilverma41/VimSetup.git
mv ~/VimSetup/.vi* ~/.
mv ~/VimSetup/.nvi* ~/.
mv ~/VimSetup/.gi* ~/.
mv ~/VimSetup/* ~/.
~/renameVimSetup.sh
~/renameVimSetup2.sh
vim ~/.vimrc
```
#### Inside the file
```
:PlugInstall (sometimes may have to :PlugClean and then :PlugInstall)
```

```
rm ~/renameVimSetup*
```

# Bashrc Setup

Paste at the end of the ```.bashrc``` file
(some additional checks to avoid this failure: https://askubuntu.com/questions/591937/no-value-for-term-and-no-t-specified)
```
if [[ $- == *i* ]]; then
  export PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;6m\][\w\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\]\[\033[38;5;6m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"
fi
```

# Terminal Settings

```
Text: #C3D0D1
Background: #002B36
```
