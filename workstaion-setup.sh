#!/bin/bash

set -e -u
set -x

_main() {

	#disable_rootpasswd
	install_brew
	install_pip
	install_python_packages
        install_git_hooks
	install_packages
	setup_environment

}

disable_rootpasswd() {
	echo "pivotalit    ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /tmp/tmp_sudoers.d
	echo ' ' | sudo -kS cp -f /tmp/tmp_sudoers.d /etc/sudoers.d/pivotalit

}

install_brew() {
	if ! which brew; then
		yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
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
		pycharm
		intellij-idea
		eclipse-cpp
		clion
	)

	brew update

	brew tap caskroom/versions
	
	brew install gcc@6

	brew install openssl && brew link openssl --force

	brew cask install "${CASK_APPS[@]}"

	brew install "${APPS[@]}" "${LIBS[@]}"

}

install_pip() {
        if ! which pip; then
		brew install wget
       		wget https://bootstrap.pypa.io/get-pip.py
		sudo python get-pip.py
 
	fi
}

install_python_packages() {
        local packages=(
                psutil
                lockfile
                paramiko
                psi
                setuptools
                epydoc
        )
        pip install --user "${packages[@]}"
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

setup_environment() {
	echo 127.0.0.1$'\t'$HOSTNAME | sudo tee -a /etc/hosts
	sudo touch /etc/sysctl.conf 
	echo "kern.sysv.shmmax=2147483648" | sudo tee -a /etc/sysctl.conf
	echo "kern.sysv.shmmin=1" | sudo tee -a /etc/sysctl.conf
	echo "kern.sysv.shmmni=64" | sudo tee -a /etc/sysctl.conf
	echo "kern.sysv.shmseg=16" | sudo tee -a /etc/sysctl.conf
	echo "kern.sysv.shmall=524288" | sudo tee -a /etc/sysctl.conf
	echo "kern.maxfiles=65535" | sudo tee -a /etc/sysctl.conf
	echo "kern.maxfilesperproc=65535" | sudo tee -a /etc/sysctl.conf
	echo "net.inet.tcp.msl=60" | sudo tee -a /etc/sysctl.conf
	echo "export MAKEFLAGS='-j4'" | sudo tee -a ~/.bashrc
	echo export PGHOST="$(hostname)" | sudo tee -a ~/.bashrc
	cd $HOME && git clone https://github.com/greenplum-db/gpdb.git
	cd $HOME/gpdb && ./configure --with-perl --with-python --with-libxml \
        --enable-debug --enable-cassert --disable-orca --disable-gpcloud --disable-gpfdist \
        --prefix=$HOME/gpdb.master
	make 
	make install
	sudo shutdown -r now
}

_main "$@"
