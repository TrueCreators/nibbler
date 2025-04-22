#!/bin/bash

# Скрипт для установки всех необходимых зависимостей из исходных кодов без использования пакетных менеджеров

echo "Установка зависимостей для Nibbler..."

# Устанавливаем директории для установки
INSTALL_DIR="$HOME/.local"
BUILD_DIR="$HOME/build_libs"

# Создаем директории, если они не существуют
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include"
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$BUILD_DIR"

# Добавляем директории в PATH, LD_LIBRARY_PATH и PKG_CONFIG_PATH
export PATH="$INSTALL_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export CPATH="$INSTALL_DIR/include:$CPATH"
export LIBRARY_PATH="$INSTALL_DIR/lib:$LIBRARY_PATH"

echo "Начинаем установку библиотек..."

# Функция для компиляции и установки SDL2
install_sdl2() {
    echo "Установка SDL2 из исходников..."
    cd "$BUILD_DIR"
    if [ ! -d "SDL2" ]; then
        # Скачиваем исходники SDL2
        wget https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
        tar -xzf SDL2-2.0.22.tar.gz
        mv SDL2-2.0.22 SDL2
        cd SDL2
        
        # Конфигурируем и компилируем
        ./configure --prefix="$INSTALL_DIR"
        make -j4
        make install
        echo "SDL2 установлен в $INSTALL_DIR"
    else
        echo "SDL2 уже установлен."
    fi
}

# Функция для компиляции и установки SDL2_image
install_sdl2_image() {
    echo "Установка SDL2_image из исходников..."
    cd "$BUILD_DIR"
    if [ ! -d "SDL2_image" ]; then
        # Скачиваем исходники SDL2_image
        wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
        tar -xzf SDL2_image-2.0.5.tar.gz
        mv SDL2_image-2.0.5 SDL2_image
        cd SDL2_image
        
        # Конфигурируем и компилируем
        ./configure --prefix="$INSTALL_DIR"
        make -j4
        make install
        echo "SDL2_image установлен в $INSTALL_DIR"
    else
        echo "SDL2_image уже установлен."
    fi
}

# Функция для компиляции и установки SDL2_ttf
install_sdl2_ttf() {
    echo "Установка SDL2_ttf из исходников..."
    cd "$BUILD_DIR"
    if [ ! -d "SDL2_ttf" ]; then
        # Скачиваем исходники SDL2_ttf
        wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.18.tar.gz
        tar -xzf SDL2_ttf-2.0.18.tar.gz
        mv SDL2_ttf-2.0.18 SDL2_ttf
        cd SDL2_ttf
        
        # Конфигурируем и компилируем
        ./configure --prefix="$INSTALL_DIR"
        make -j4
        make install
        echo "SDL2_ttf установлен в $INSTALL_DIR"
    else
        echo "SDL2_ttf уже установлен."
    fi
}

# Функция для компиляции и установки Raylib
install_raylib() {
    echo "Установка Raylib из исходников..."
    cd "$BUILD_DIR"
    if [ ! -d "raylib" ]; then
        # Клонируем репозиторий Raylib
        git clone https://github.com/raysan5/raylib.git
        cd raylib/src
        
        # Компилируем Raylib
        make PLATFORM=PLATFORM_DESKTOP PREFIX="$INSTALL_DIR"
        make install PREFIX="$INSTALL_DIR"
        echo "Raylib установлен в $INSTALL_DIR"
    else
        echo "Raylib уже установлен."
    fi
}

# Функция для компиляции и установки SFML
install_sfml() {
    echo "Установка SFML из исходников..."
    cd "$BUILD_DIR"
    if [ ! -d "SFML" ]; then
        # Клонируем репозиторий SFML
        git clone https://github.com/SFML/SFML.git
        cd SFML
        
        # Создаем директорию для сборки
        mkdir -p build
        cd build
        
        # Компилируем SFML
        cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" ..
        make -j4
        make install
        echo "SFML установлен в $INSTALL_DIR"
    else
        echo "SFML уже установлен."
    fi
}

# Установка шрифтов DejaVu
install_dejavu_fonts() {
    echo "Установка шрифтов DejaVu..."
    cd "$BUILD_DIR"
    if [ ! -d "dejavu-fonts" ]; then
        # Создаем директорию для шрифтов
        mkdir -p "$INSTALL_DIR/share/fonts/truetype/dejavu"
        
        # Скачиваем и распаковываем шрифты
        wget https://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2
        tar -xjf dejavu-fonts-ttf-2.37.tar.bz2
        mv dejavu-fonts-ttf-2.37 dejavu-fonts
        
        # Копируем шрифты в директорию установки
        cp dejavu-fonts/ttf/DejaVuSans*.ttf "$INSTALL_DIR/share/fonts/truetype/dejavu/"
        
        # Создаем символическую ссылку для программы
        mkdir -p "$HOME/.fonts"
        ln -sf "$INSTALL_DIR/share/fonts/truetype/dejavu/DejaVuSans.ttf" "$HOME/.fonts/DejaVuSans.ttf"
        
        # Обновляем кэш шрифтов если fc-cache доступен
        if command -v fc-cache &> /dev/null; then
            fc-cache -f -v
        fi
        
        echo "Шрифты DejaVu установлены в $INSTALL_DIR/share/fonts"
    else
        echo "Шрифты DejaVu уже установлены."
    fi
}

# Запускаем установку всех компонентов
install_sdl2
install_sdl2_image
install_sdl2_ttf
install_raylib
install_sfml
install_dejavu_fonts

# Добавляем пути в .bashrc, если они еще не добавлены
if ! grep -q "LD_LIBRARY_PATH.*$INSTALL_DIR/lib" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Nibbler dependencies paths" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "export LD_LIBRARY_PATH=\"$INSTALL_DIR/lib:\$LD_LIBRARY_PATH\"" >> "$HOME/.bashrc"
    echo "export PKG_CONFIG_PATH=\"$INSTALL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> "$HOME/.bashrc"
    echo "export CPATH=\"$INSTALL_DIR/include:\$CPATH\"" >> "$HOME/.bashrc"
    echo "export LIBRARY_PATH=\"$INSTALL_DIR/lib:\$LIBRARY_PATH\"" >> "$HOME/.bashrc"
fi

# Создаем ссылки на библиотеки в рабочей директории проекта
create_symlinks() {
    cd "$(dirname "$0")/.."
    
    # SDL
    if [ -f "$INSTALL_DIR/lib/libSDL2.so" ]; then
        ln -sf "$INSTALL_DIR/lib/libSDL2.so" libSDL2-2.0.so.0
    fi
    
    # SFML
    if [ -f "$INSTALL_DIR/lib/libsfml-graphics.so" ]; then
        ln -sf "$INSTALL_DIR/lib/libsfml-graphics.so" libsfml-graphics.so.2.4
        ln -sf "$INSTALL_DIR/lib/libsfml-window.so" libsfml-window.so.2.4
        ln -sf "$INSTALL_DIR/lib/libsfml-system.so" libsfml-system.so.2.4
    fi
}

create_symlinks

echo "Все зависимости установлены в директорию $INSTALL_DIR"
echo "Чтобы применить изменения, выполните: source ~/.bashrc"
echo "Или перезапустите терминал."
echo "Путь к шрифту DejaVuSans.ttf: $INSTALL_DIR/share/fonts/truetype/dejavu/DejaVuSans.ttf" 