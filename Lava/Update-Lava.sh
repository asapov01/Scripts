#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update {
  printGreen "Розпочалось оновлення Lava Node,актуальна версія мережі: Testnet2 version: v0.21.1.2" && sleep 1
  printGreen "Зупинка Lava node"
  sudo systemctl stop lavad && sleep 3
  printGreen "Backup файлів: priv_validator.key.json,node_key.json до новоствореної папки  /root/lavabackupfiles/"
  mkdir -p /root/lavabackupfiles  
  cp /root/.lava/config/priv_validator_key.json /root/lavabackupfiles/
  cp /root/.lava/config/node_key.json /root/lavabackupfiles/
  printGreen "Backup закінчено" && sleep 1
  printGreen "Скидаємо попередні данні ноди..." && sleep 1
  lavad tendermint unsafe-reset-all --home $HOME/.lava 
  printGreen "Копіюємо новий genesis.json мережі Testnet2" && sleep 2
  wget -O $HOME/.lava/config/genesis.json "https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json" && sleep 1
  sleep 5
  printGreen "Оновлюємо Binary Version Lava"
  cd $HOME/.lava
  git pull
  git checkout v0.21.1.2
  make install
  lavad version --long | grep -e version -e commit && sleep 2

  printGreen "Оновлення файлів config.toml та client.toml..."

sudo sed -i 's/pprof_laddr = "0\.0\.0\.0:6060"/pprof_laddr = "0\.0\.0\.0:6160"/' $HOME/.lava/config/config.toml
sudo sed -i 's/laddr = "tcp:\/\/0\.0\.0\.0:26657"/laddr = "tcp:\/\/0\.0\.0\.0:16657"/' $HOME/.lava/config/config.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1327"/' "$HOME/.lava/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:19090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:19091\"|" $HOME/.lava/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:16656"|' $HOME/.lava/config/config.toml


  sed -i \
    -e 's/timeout_commit = ".*"/timeout_commit = "30s"/g' \
    -e 's/timeout_propose = ".*"/timeout_propose = "1s"/g' \
    -e 's/timeout_precommit = ".*"/timeout_precommit = "1s"/g' \
    -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "500ms"/g' \
    -e 's/timeout_prevote = ".*"/timeout_prevote = "1s"/g' \
    -e 's/timeout_prevote_delta = ".*"/timeout_prevote_delta = "500ms"/g' \
    -e 's/timeout_propose_delta = ".*"/timeout_propose_delta = "500ms"/g' \
    -e 's/skip_timeout_commit = ".*"/skip_timeout_commit = false/g' \
    $HOME/.lava/config/client.toml

  printGreen "Завантажуємо снепшот для прискорення синхронізації"
    SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
    curl "https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"


  printGreen "Файли config.toml та client.toml успішно оновлено" && sleep 1
  printGreen "Запускаємо Lava Node..." && sleep 1
  systemctl restart lavad && sleep 5
  printGreen "Ноду успішно оновлено. Мережа Testnet2. version: v0.21.1.2" && sleep 3
  printGreen "Запускаємо журнал логів..." && sleep 3
  printGreen "Спочатку ви можете побачити помилку Connection is closed, через 10-15 секунд нода розпочне свою роботу."
  journalctl -u lavad -f -o cat 
}

logo
update

cd ~
