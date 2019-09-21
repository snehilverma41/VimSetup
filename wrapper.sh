echo "sudo apt-get install fonts-powerline"
sudo apt-get install fonts-powerline
echo "./renameVimSetup.sh"
./renameVimSetup.sh
echo "./renameVimSetup2.sh"
./renameVimSetup2.sh
echo "mv ~/VimSetup/.vi* ~/."
mv ~/VimSetup/.vi* ~/.
echo "mv ~/VimSetup/.nvi* ~/."
mv ~/VimSetup/.nvi* ~/.
echo "mv ~/VimSetup/.gi* ~/."
mv ~/VimSetup/.gi* ~/.
echo "vim +'PlugClean' +qa"
vim +'PlugClean' +qa
echo "vim +'PlugInstall --sync' +qa"
vim +'PlugInstall --sync' +qa
