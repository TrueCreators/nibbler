#!/bin/bash

# Скрипт для установки всех необходимых зависимостей

echo "Установка зависимостей для Nibbler..."

# Проверка наличия пакетного менеджера
if command -v apt &> /dev/null; then
    PACKAGE_MANAGER="apt"
elif command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v brew &> /dev/null; then
    PACKAGE_MANAGER="brew"
else
    echo "Не найден поддерживаемый пакетный менеджер. Пожалуйста, установите зависимости вручную."
    exit 1
fi

echo "Используем пакетный менеджер: $PACKAGE_MANAGER"

# Функция для установки пакетов в зависимости от пакетного менеджера
install_packages() {
    echo "Установка пакетов: $@"
    case $PACKAGE_MANAGER in
        apt|apt-get)
            $PACKAGE_MANAGER install -y "$@"
            ;;
        dnf|yum)
            $PACKAGE_MANAGER install -y "$@"
            ;;
        pacman)
            $PACKAGE_MANAGER -S --noconfirm "$@"
            ;;
        brew)
            $PACKAGE_MANAGER install "$@"
            ;;
    esac
}

# Обновление репозиториев
case $PACKAGE_MANAGER in
    apt|apt-get)
        $PACKAGE_MANAGER update
        ;;
    dnf|yum)
        $PACKAGE_MANAGER check-update
        ;;
    pacman)
        $PACKAGE_MANAGER -Sy
        ;;
    brew)
        $PACKAGE_MANAGER update
        ;;
esac

# Установка общих зависимостей для разработки
echo "Установка основных инструментов разработки..."
case $PACKAGE_MANAGER in
    apt|apt-get)
        install_packages build-essential cmake
        ;;
    dnf|yum)
        install_packages gcc-c++ cmake
        ;;
    pacman)
        install_packages base-devel cmake
        ;;
    brew)
        install_packages cmake
        ;;
esac

# Установка зависимостей для SDL2
echo "Установка SDL2..."
case $PACKAGE_MANAGER in
    apt|apt-get)
        install_packages libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
        ;;
    dnf|yum)
        install_packages SDL2-devel SDL2_image-devel SDL2_ttf-devel
        ;;
    pacman)
        install_packages sdl2 sdl2_image sdl2_ttf
        ;;
    brew)
        install_packages sdl2 sdl2_image sdl2_ttf
        ;;
esac

# Установка зависимостей для Raylib
echo "Установка зависимостей для Raylib..."
case $PACKAGE_MANAGER in
    apt|apt-get)
        install_packages libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev
        ;;
    dnf|yum)
        install_packages alsa-lib-devel libX11-devel libXrandr-devel libXi-devel mesa-libGL-devel mesa-libGLU-devel libXcursor-devel libXinerama-devel
        ;;
    pacman)
        install_packages alsa-lib libx11 libxrandr libxi mesa glu libxcursor libxinerama
        ;;
    brew)
        install_packages alsa-lib libx11 libxrandr libxi mesa glu
        ;;
esac

# Проверка наличия Raylib в системе
RAYLIB_INSTALLED=false
case $PACKAGE_MANAGER in
    apt|apt-get)
        if dpkg -l | grep -q "libraylib"; then
            RAYLIB_INSTALLED=true
        elif apt-cache search libraylib | grep -q "libraylib"; then
            echo "Устанавливаем Raylib из репозитория..."
            install_packages libraylib-dev
            RAYLIB_INSTALLED=true
        fi
        ;;
    dnf|yum)
        if $PACKAGE_MANAGER list installed | grep -q "raylib"; then
            RAYLIB_INSTALLED=true
        elif $PACKAGE_MANAGER search raylib | grep -q "raylib"; then
            echo "Устанавливаем Raylib из репозитория..."
            install_packages raylib-devel
            RAYLIB_INSTALLED=true
        fi
        ;;
    pacman)
        if pacman -Q raylib &> /dev/null; then
            RAYLIB_INSTALLED=true
        elif pacman -Ss raylib | grep -q "raylib"; then
            echo "Устанавливаем Raylib из репозитория..."
            install_packages raylib
            RAYLIB_INSTALLED=true
        fi
        ;;
    brew)
        if brew list | grep -q "raylib"; then
            RAYLIB_INSTALLED=true
        else
            echo "Устанавливаем Raylib из репозитория Homebrew..."
            install_packages raylib
            RAYLIB_INSTALLED=true
        fi
        ;;
esac

# Компиляция Raylib из исходников, если не удалось установить из репозитория
if [ "$RAYLIB_INSTALLED" = false ]; then
    echo "Установка Raylib из исходных кодов..."
    # Создание временного каталога для установки
    INSTALL_DIR="$HOME/.local"
    mkdir -p "$INSTALL_DIR"
    
    # Клонирование Raylib
    if [ ! -d "/tmp/raylib" ]; then
        git clone https://github.com/raysan5/raylib.git /tmp/raylib
        cd /tmp/raylib/src
        make PLATFORM=PLATFORM_DESKTOP PREFIX="$INSTALL_DIR"
        make install PREFIX="$INSTALL_DIR"
        
        # Добавление пути к библиотекам в LD_LIBRARY_PATH
        echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_DIR/lib" >> "$HOME/.bashrc"
        echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$INSTALL_DIR/lib/pkgconfig" >> "$HOME/.bashrc"
        
        echo "Raylib установлен в $INSTALL_DIR. Пожалуйста, перезапустите терминал или выполните:"
        echo "source ~/.bashrc"
    fi
fi

# Установка зависимостей для SFML
echo "Установка SFML..."
case $PACKAGE_MANAGER in
    apt|apt-get)
        install_packages libsfml-dev
        ;;
    dnf|yum)
        install_packages SFML-devel
        ;;
    pacman)
        install_packages sfml
        ;;
    brew)
        install_packages sfml
        ;;
esac

# Проверка наличия шрифта DejaVuSans
if [ ! -f "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" ]; then
    echo "Установка шрифтов DejaVu..."
    case $PACKAGE_MANAGER in
        apt|apt-get)
            install_packages fonts-dejavu
            ;;
        dnf|yum)
            install_packages dejavu-sans-fonts
            ;;
        pacman)
            install_packages ttf-dejavu
            ;;
        brew)
            install_packages font-dejavu
            ;;
    esac
fi

echo "Все зависимости установлены!"
echo "Перезапустите терминал или выполните 'source ~/.bashrc', чтобы все настройки вступили в силу." 