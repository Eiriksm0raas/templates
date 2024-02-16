FROM ubuntu:latest
WORKDIR /root/dev

RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get install -y curl g++ git ripgrep &&\
	apt-get clean &&\
	rm -rf /var/lib/apt/lists/*

RUN cd .. &&\
	curl -L "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz"\
	-o nvim.tar.gz &&\
	tar xzvf nvim.tar.gz &&\
	ln -s /root/nvim-linux64/bin/nvim /usr/local/bin/nvim &&\
	rm -f nvim.tar.gz &&\
	nvim --headless "+Lazy! sync" +qa

RUN mkdir -p /root/.config/nvim &&\
	curl -L "https://raw.githubusercontent.com/Eiriksm0raas/templates/main/nvim/min.lua"\
	-o /root/.config/nvim/init.lua
