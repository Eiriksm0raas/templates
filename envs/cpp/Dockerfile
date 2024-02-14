FROM ubuntu
WORKDIR /root/dev

RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get install -y\
	curl\
	neovim\
	g++

RUN mkdir -p /root/.config/nvim &&\
	curl -L "https://raw.githubusercontent.com/Eiriksm0raas/templates/main/nvim/full.lua"\
	-o /root/.config/nvim/init.lua
