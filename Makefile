-include .env

.PHONY: all build test clean deploy help install format 

all: clean remove install update build

install: foundry slither aderyn surya

foundry:
	rm -rf foundry && \
	mkdir foundry && \
	cd foundry && \
	forge init && \
	forge install github.com/smartcontractkit/chainlink-brownie-contracts && \
	forge install transmissions11/solmate && \
	forge install Cyfrin/foundry-devops && \
	forge install OpenZeppelin/openzeppelin-contracts-upgradeable && \
	rm -rf script test src 

slither:
	pipx install git+https://github.com/crytic/slither.git && \
	export PATH="$PATH:/root/.local/bin"

aderyn:
	curl --proto '=https' --tlsv1.2 -LsSf https://github.com/cyfrin/aderyn/releases/latest/download/aderyn-installer.sh | bash

surya:
	npm install -g surya
