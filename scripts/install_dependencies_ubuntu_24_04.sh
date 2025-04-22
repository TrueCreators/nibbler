#!/bin/bash

# Скрипт для установки всех необходимых зависимостей в Ubuntu 24.04

echo "Установка зависимостей для Nibbler на Ubuntu 24.04..."

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

# Проверка наличия установленного пакета raylib
if dpkg -l | grep -q "libraylib"; then
    echo "Raylib уже установлен через пакетный менеджер"
else
    # Клонирование и установка Raylib
    if [ ! -d "/tmp/raylib" ]; then
        git clone https://github.com/raysan5/raylib.git /tmp/raylib
        cd /tmp/raylib/src
        make PLATFORM=PLATFORM_DESKTOP
        sudo make install
    fi
fi

# Установка зависимостей для SFML
echo "Установка SFML..."
sudo apt-get install -y libsfml-dev

# В Ubuntu 24.04 может потребоваться создание символических ссылок для правильной работы SFML 
# если версии библиотек изменились
SFML_LIBS=$(find /usr/lib -name "libsfml-graphics.so.*" | head -n 1)
if [ -n "$SFML_LIBS" ]; then
    SFML_VERSION=$(basename $SFML_LIBS | sed 's/libsfml-graphics.so.//')
    echo "Найдена версия SFML: $SFML_VERSION"
    
    # Создание символических ссылок для библиотек SFML 2.4 если установлена более новая версия
    if [ "$SFML_VERSION" != "2.4" ]; then
        echo "Создание символических ссылок для совместимости с SFML 2.4..."
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libsfml-graphics.so.$SFML_VERSION /usr/lib/x86_64-linux-gnu/libsfml-graphics.so.2.4
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libsfml-window.so.$SFML_VERSION /usr/lib/x86_64-linux-gnu/libsfml-window.so.2.4
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libsfml-system.so.$SFML_VERSION /usr/lib/x86_64-linux-gnu/libsfml-system.so.2.4
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libsfml-audio.so.$SFML_VERSION /usr/lib/x86_64-linux-gnu/libsfml-audio.so.2.4
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libsfml-network.so.$SFML_VERSION /usr/lib/x86_64-linux-gnu/libsfml-network.so.2.4
    fi
fi

# Проверка наличия шрифта DejaVuSans.ttf
if [ ! -f "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" ]; then
    echo "Установка шрифтов DejaVu..."
    sudo apt-get install -y fonts-dejavu
fi

echo "Все зависимости установлены!" 