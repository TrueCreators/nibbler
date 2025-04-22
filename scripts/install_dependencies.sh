#!/bin/bash

# Скрипт для установки всех необходимых зависимостей

echo "Установка зависимостей для Nibbler..."

# Обновление репозиториев
sudo apt-get update

# Установка общих зависимостей для разработки
sudo apt-get install -y build-essential cmake

# Установка зависимостей для SDL
echo "Установка SDL2..."
sudo apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev

# Установка зависимостей для Raylib
echo "Установка Raylib..."
sudo apt-get install -y libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev

# Клонирование и установка Raylib
if [ ! -d "/tmp/raylib" ]; then
    git clone https://github.com/raysan5/raylib.git /tmp/raylib
    cd /tmp/raylib/src
    make PLATFORM=PLATFORM_DESKTOP
    sudo make install
fi

# Установка зависимостей для SFML
echo "Установка SFML..."
sudo apt-get install -y libsfml-dev

echo "Все зависимости установлены!" 