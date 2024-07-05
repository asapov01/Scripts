#!/bin/bash

# Перевірка версії Ubuntu
ubuntu_version=$(lsb_release -d | awk -F"\t" '{print $2}')

# Отримання інформації про доступний простір SSD/NVME
if lsblk | grep -q "nvme"; then
    ssd_type="NVME"
    ssd_available=$(df -h / | grep '/' | awk '{print $4}')
elif lsblk | grep -q "sda"; then
    ssd_type="SSD"
    ssd_available=$(df -h / | grep '/' | awk '{print $4}')
else
    ssd_type="Невідомий тип"
    ssd_available="Невідомий обсяг"
fi

# Отримання інформації про доступну пам'ять RAM
ram_available=$(free -h | grep Mem | awk '{print $7}')

# Перевірка кількості ядер CPU на сервері
cpu_available=$(nproc)

# Отримання архітектури процесора
cpu_type=$(uname -m)

# Перегляд зайнятих портів
occupied_ports=$(ss -tulnp | grep 'LISTEN')

# Перевірка наявності Go
if go_version=$(go version 2>/dev/null); then
    go_status="встановлено ($go_version)"
else
    go_status="не встановлено"
fi

# Перевірка наявності screen
if screen -version &> /dev/null; then
    screen_status="встановлено"
else
    screen_status="не встановлено"
fi

# Перевірка наявності Docker
if docker_version=$(docker --version 2>/dev/null); then
    docker_status="встановлено ($docker_version)"
else
    docker_status="не встановлено"
fi

# Перевірка наявності .bash_profile та створення, якщо потрібно
bash_profile="$HOME/.bash_profile"
if [ ! -f "$bash_profile" ]; then
    touch "$bash_profile"
fi

# Кольори
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Без кольору

# Виведення інформації
echo ""
echo -e "${GREEN}На вашому сервері доступно:${NC}"
echo ""
echo -e "${GREEN}Ubuntu: ${RED}$ubuntu_version${NC}"
echo -e "${GREEN}Тип диска: ${RED}$ssd_type${NC}"
echo -e "${GREEN}SSD/NVME доступно: ${RED}$ssd_available${NC}"
echo -e "${GREEN}RAM доступно: ${RED}$ram_available${NC}"
echo -e "${GREEN}CPU ядер на сервері: ${RED}$cpu_available${NC}"
echo -e "${GREEN}Архітектура процесора: ${RED}$cpu_type${NC}"
echo -e "${GREEN}Мова програмування GO: ${RED}$go_status${NC}"
echo -e "${GREEN}Утиліта screen: ${RED}$screen_status${NC}"
echo -e "${GREEN}Docker: ${RED}$docker_status${NC}"
echo -e "${GREEN}Зайняті порти:${NC}"
echo -e "${occupied_ports}"
