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


sudo sed -i 's/pprof_laddr = "0\.0\.0\.0:6060"/pprof_laddr = "0\.0\.0\.0:6160"/' $HOME/.lava/config/config.toml
sudo sed -i 's/laddr = "tcp:\/\/0\.0\.0\.0:26657"/laddr = "tcp:\/\/0\.0\.0\.0:16657"/' $HOME/.lava/config/config.toml
sudo sed -i 's/node = "tcp:\/\/localhost:26657"/node = "tcp:\/\/localhost:16657"/' $HOME/.lava/config/client.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1327"/' "$HOME/.lava/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:19090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:19091\"|" $HOME/.lava/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:16656"|' $HOME/.lava/config/config.toml

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
printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo.catching_up"
printGreen "Порти які використовує ваша нода: 16656,16657,6160,1327,19090,19091"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
printDelimiter

}
install
