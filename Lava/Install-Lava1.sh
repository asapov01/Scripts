#!/bin/bash

function install() {
clear
function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

echo ""
printGreen "Введіть ім'я для вашої ноди:"
read -r NODE_MONIKER

CHAIN_ID=lava-testnet-2
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.profile
source $HOME/.profile

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

git clone https://github.com/lavanet/lava-config.git
cd lava-config/testnet-2
source setup_config/setup_config.sh

echo "Lava config file path: $lava_config_folder"
mkdir -p $lavad_home_folder
mkdir -p $lava_config_folder
cp default_lavad_config_files/* $lava_config_folder


lavad_binary_path="$HOME/go/bin/"
mkdir -p $lavad_binary_path
wget https://lava-binary-upgrades.s3.amazonaws.com/testnet-2/genesis/lavad
chmod +x lavad
cp lavad /usr/local/bin

  sleep 1
  lavad config keyring-backend test
  lavad config chain-id $CHAIN_ID
  lavad init "$NODE_MONIKER" --chain-id $CHAIN_ID


sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:32658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:32657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6660\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:32656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":32660\"%" $HOME/.lava/config/config.toml && sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9690\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9691\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1917\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:9145\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:9146\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:9145\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:9146\"%" $HOME/.lava/config/app.toml && sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:32657\"%" $HOME/.lava/config/client.toml 

echo "[Unit]
Description=Lava Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start --home=$lavad_home_folder --p2p.seeds $seed_node
Restart=always
RestartSec=180
LimitNOFILE=infinity
LimitNPROC=infinity
[Install]
WantedBy=multi-user.target" >lavad.service
sudo mv lavad.service /lib/systemd/system/lavad.service

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"

rm -rf $HOME/lava-config

sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad && sleep 5


printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 1917,32660,6660,32656,32657,32658,9691,9690"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
printDelimiter

}
install
