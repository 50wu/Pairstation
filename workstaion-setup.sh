#!/bin/bash

set -e -u
set -x

_main() {

	disable_rootpasswd
	install_brew
	install_packages
	install_pip
	install_python_packages
	install_git_hooks
}

install_pip() {
	if ! which pip; then
		easy_install pip
	fi
}

install_python_packages() {
	local packages=(
		psutil
		lockfile
		paramiko
		psi
		etuptools
		epydoc
	)
	pip install --user "${packages[@]}"
}

disable_rootpasswd() {
	echo "pivotalit    ALL=(ALL) NOPASSWD: ALL" > /tmp/tmp_sudoers.d
	echo '' | sudo -kS cp -f /tmp/tmp_sudoers.d /etc/sudoers.d/pivotalit

}

install_brew() {
	if ! which brew; then
		yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
}

install_git_hooks() {
	git config --global core.editor /usr/bin/vim
	git config --global transfer.fsckobjects true
	git clone https://github.com/pivotal-cf/git-hooks-core $HOME/git-hooks-core
	git config --global --add core.hooksPath $HOME/git-hooks-core
	os_name=$(uname | awk '{print tolower($1)}')
	curl -o cred-alert-cli \
	https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_${os_name}
	chmod 755 cred-alert-cli
	mv cred-alert-cli /usr/local/bin
}

install_packages() {
	readonly local APPS=(
		fish
		git
		gdb
		cmake
		p7zip
		ninja
		ctags
		cscope
		ssh-copy-id
		hub
		rbenv
		ruby-build
		autoconf
		node
		go
		wget
		ccache
		docker-compose
		docker-machine
		parallel
		shellcheck
		apr
	)

	local LIBS=(
		libevent
		libyaml
	)

	readonly local CASK_APPS=(
		iterm2
		macvim
		emacs
		fluid
		keycastr
		flycut
		google-chrome
		java8
		shiftit
		zoomus
		pycharm
		intellij-idea
		eclipse-cpp
		clion
	)

	brew update

	brew tap caskroom/versions
	
	brew install gcc@6

	brew cask install "${CASK_APPS[@]}"

	brew install "${APPS[@]}" "${LIBS[@]}"

}


_main "$@"
