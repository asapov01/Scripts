#!/bin/bash

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function printDelimiter {
  echo "==========================================="
}

function holograph_faucet() {
  holograph faucet 
}

clear
logo
printGreen "Перед початком встановлення вам потрібно виконати всі попередні кроки з гайду, а саме:"
echo ""
echo "1. Додати всі тестові мережі собі в Metamask"
echo "2. Запросити тестові токени на всі тестові мережі"
echo "3. Створити RPC в Alchemy"
echo ""
read -p "$(printGreen 'Якщо ви виконали всі умови, та вперше втановлюєте ноду, введіть 1. Якщо ви запросили вдруге 100 $HLG та маєте на балансі 200 $HLG у 3 мережах, введіть 2 [1/2]: ')" answer

if [ "$answer" = "1" ]; then
  printGreen "Розпочалось встановлення Holograph..."
  install
elif [ "$answer" = "2" ]; then
  done2
fi

function install() {
  printGreen "Встановлення необхідних програмних компонентів..."
  echo ""

  sudo apt update && sudo apt upgrade -y
  sudo apt install curl -y
  sudo apt-get install nodejs -y
  sudo apt-get install -f

  echo ""
  printGreen "Встановлення Holograph..."
  printGreen "Ігноруйте подальші повідомлення npm WARN deprecated та run npm fund - це просто повідомлення про застарілу версію npm" && sleep 4
  echo ""
  npm install -g @holographxyz/cli
  echo ""
  printGreen "Оберіть мережі goerli, mumbai, fuji (Користуйтесь стрілками вниз-вверх, Space - для вибору мереж, ENTER - після вибору усіх 3 мереж."
  printGreen "Та перейдіть до гайду, для виконання наступних кроків по встановленню" 
  echo "" && sleep 3
  holograph config

  if [ $? -eq 0 ]; then
    for i in {1..3}; do
      holograph_faucet
    done
  fi
}

function done2() {
  printGreen "Створюємо screen з назвою holograph - для стабільної та безперебійної роботи нашої ноди. Вийти з режиму screen - Ctrl + A + D" && sleep 4
  screen -S holograph && sleep 2
  if [ $? -eq 0 ]; then
    for i in {1..3}; do
      holograph operator:bond
    done
  fi
}

install
done2
