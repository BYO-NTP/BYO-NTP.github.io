#!/bin/sh

install_linux()
{
	curl -sS https://starship.rs/install.sh | sh

	apt install -y zsh zsh-autosuggestions
	chsh -s /usr/bin/zsh root

	curl -sSo ~/.zshrc https://byo-ntp.github.io/recipes/tools/zsh/config.txt

	mkdir ~/.config
	curl -sSo ~/.config/starship.toml https://byo-ntp.github.io/recipes/tools/zsh/starship.txt
}

install_freebsd()
{
	pkg install -y zsh zsh-autosuggestions starship && \
	chpass -s zsh root

	fetch -o ~/.zshrc https://byo-ntp.github.io/recipes/tools/zsh/config.txt

	mkdir ~/.config
	fetch -o ~/.config/starship.toml https://byo-ntp.github.io/recipes/tools/zsh/starship.txt
}

case "$(uname -s)" in
	FreeBSD)
		install_freebsd
	;;
	Linux)
		install_linux
	;;
	*)
		echo "ERR: Unsupported platform $(uname -s). Please file a feature request."
		exit 1
	;;
esac
