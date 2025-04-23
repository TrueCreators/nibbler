#!/bin/sh

# Скрипт для установки всех необходимых зависимостей из исходных кодов без использования sudo

echo "Установка зависимостей для Nibbler без прав администратора..."

# Получаем путь к корневой директории проекта
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

# Устанавливаем директории для установки библиотек
SDL_DIR="$PROJECT_ROOT/libs/sdl"
SFML_DIR="$PROJECT_ROOT/libs/sfml"
RAYLIB_DIR="$PROJECT_ROOT/libs/raylib"
DEJAVU_INSTALL_DIR="$PROJECT_ROOT/libs/fonts"

# Создаем директории, если они не существуют
mkdir -p "$SDL_DIR/src"
mkdir -p "$SDL_DIR/lib"
mkdir -p "$SDL_DIR/include"
mkdir -p "$SFML_DIR/src"
mkdir -p "$SFML_DIR/lib"
mkdir -p "$SFML_DIR/include"
mkdir -p "$RAYLIB_DIR/src"
mkdir -p "$RAYLIB_DIR/lib"
mkdir -p "$RAYLIB_DIR/include"
mkdir -p "$DEJAVU_INSTALL_DIR"

# Проверка наличия библиотек и запрос на очистку
check_existing_libs() {
    local libs_exist=false
    local should_clean=false
    
    echo "Проверка наличия ранее установленных библиотек..."
    
    # Проверяем библиотеки SDL
    if [ -d "$SDL_DIR/lib" ] && [ "$(ls -A "$SDL_DIR/lib" 2>/dev/null)" ]; then
        echo "Обнаружены файлы SDL библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки SFML
    if [ -d "$SFML_DIR/lib" ] && [ "$(ls -A "$SFML_DIR/lib" 2>/dev/null)" ]; then
        echo "Обнаружены файлы SFML библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки Raylib
    if [ -d "$RAYLIB_DIR/lib" ] && [ "$(ls -A "$RAYLIB_DIR/lib" 2>/dev/null)" ]; then
        echo "Обнаружены файлы Raylib библиотеки"
        libs_exist=true
    fi
    
    if $libs_exist; then
        read -p "Обнаружены ранее установленные библиотеки. Очистить перед установкой новых? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            should_clean=true
        else
            echo "Продолжаю установку без очистки..."
        fi
    fi
    
    if $should_clean; then
        clean_libs
    fi
}

# Очищаем предыдущие установки
clean_libs() {
    echo "Очистка предыдущих установок..."
    
    # Очищаем исходники
    rm -rf "$SDL_DIR/src/"*
    rm -rf "$SFML_DIR/src/"*
    rm -rf "$RAYLIB_DIR/src/"*
    
    # Очищаем установленные библиотеки
    rm -rf "$SDL_DIR/lib/"*
    rm -rf "$SDL_DIR/include/"*
    rm -rf "$SFML_DIR/lib/"*
    rm -rf "$SFML_DIR/include/"*
    rm -rf "$RAYLIB_DIR/lib/"*
    rm -rf "$RAYLIB_DIR/include/"*
    
    echo "Предыдущие установки очищены."
}

# Функция для установки SDL2
install_sdl2() {
    if [ -f "$SDL_DIR/lib/libSDL2.so" ] && [ -d "$SDL_DIR/include/SDL2" ]; then
        read -p "SDL2 уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка SDL2..."
        else
            echo "Пропускаю установку SDL2..."
            return
        fi
    fi

    echo "Установка SDL2 из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2-2.0.22.tar.gz src/SDL2-2.0.22
    
    # Скачиваем исходники SDL2
    wget -P src/ https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
    tar -xzf src/SDL2-2.0.22.tar.gz -C src/
    cd src/SDL2-2.0.22
    
    # Конфигурируем и компилируем
    ./configure --prefix="$SDL_DIR"
    make -j$(nproc)
    make install
    
    # Создаем симлинк для библиотеки
    ln -sf "$SDL_DIR/lib/libSDL2.so" "$PROJECT_ROOT/libSDL2-2.0.so.0"
    
    echo "SDL2 установлен в $SDL_DIR"
}

# Функция для установки SDL2_image
install_sdl2_image() {
    if [ -f "$SDL_DIR/lib/libSDL2_image.so" ]; then
        read -p "SDL2_image уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка SDL2_image..."
        else
            echo "Пропускаю установку SDL2_image..."
            return
        fi
    fi
    
    echo "Установка SDL2_image из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2_image-2.0.5.tar.gz src/SDL2_image-2.0.5
    
    # Скачиваем исходники SDL2_image
    wget -P src/ https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
    tar -xzf src/SDL2_image-2.0.5.tar.gz -C src/
    cd src/SDL2_image-2.0.5
    
    # Конфигурируем и компилируем
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR"
    make -j$(nproc)
    make install
    echo "SDL2_image установлен в $SDL_DIR"
}

# Функция для установки SDL2_ttf
install_sdl2_ttf() {
    if [ -f "$SDL_DIR/lib/libSDL2_ttf.so" ]; then
        read -p "SDL2_ttf уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка SDL2_ttf..."
        else
            echo "Пропускаю установку SDL2_ttf..."
            return
        fi
    fi
    
    echo "Установка SDL2_ttf из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2_ttf-2.0.18.tar.gz src/SDL2_ttf-2.0.18
    
    # Скачиваем исходники SDL2_ttf
    wget -P src/ https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.18.tar.gz
    tar -xzf src/SDL2_ttf-2.0.18.tar.gz -C src/
    cd src/SDL2_ttf-2.0.18
    
    # Конфигурируем и компилируем
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR"
    make -j$(nproc)
    make install
    echo "SDL2_ttf установлен в $SDL_DIR"
}

# Функция для установки Raylib
install_raylib() {
    if [ -f "$RAYLIB_DIR/lib/libraylib.so" ] && [ -f "$RAYLIB_DIR/include/raylib.h" ]; then
        read -p "Raylib уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка Raylib..."
        else
            echo "Пропускаю установку Raylib..."
            return
        fi
    fi
    
    echo "Установка Raylib из исходников..."
    cd "$RAYLIB_DIR"
    rm -rf src/raylib
    
    # Клонируем репозиторий Raylib
    git clone https://github.com/raysan5/raylib.git src/raylib
    cd src/raylib/src
    
    # Компилируем напрямую используя GCC
    echo "Компиляция libraylib.so..."
    gcc -shared -DPLATFORM_DESKTOP -o libraylib.so \
        -fPIC \
        *.c \
        -lGL -lm -lpthread -ldl -lrt -lX11
    
    # Копируем библиотеки и заголовочные файлы
    mkdir -p "$RAYLIB_DIR/include"
    mkdir -p "$RAYLIB_DIR/lib"
    cp libraylib.so "$RAYLIB_DIR/lib/"
    cp raylib.h "$RAYLIB_DIR/include/"
    cp raymath.h "$RAYLIB_DIR/include/"
    cp rlgl.h "$RAYLIB_DIR/include/"
    
    # Создаем симлинк в корневой директории
    ln -sf "$RAYLIB_DIR/lib/libraylib.so" "$PROJECT_ROOT/libraylib.so"
    
    echo "Raylib установлен в $RAYLIB_DIR"
}

# Функция для установки SFML
install_sfml() {
    if [ -f "$SFML_DIR/lib/libsfml-graphics.so" ] && [ -d "$SFML_DIR/include/SFML" ]; then
        read -p "SFML уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка SFML..."
        else
            echo "Пропускаю установку SFML..."
            return
        fi
    fi
    
    echo "Установка SFML из исходников..."
    cd "$SFML_DIR"
    rm -rf src/SFML
    
    # Клонируем репозиторий SFML
    git clone https://github.com/SFML/SFML.git src/SFML --branch 2.5.1 --depth 1
    
    # Создаем директорию для сборки
    mkdir -p src/SFML/build
    cd src/SFML/build
    
    # Компилируем SFML
    cmake -DCMAKE_INSTALL_PREFIX="$SFML_DIR" -DBUILD_SHARED_LIBS=TRUE ..
    make -j$(nproc)
    make install
    
    # Создаем симлинки для библиотек
    ln -sf "$SFML_DIR/lib/libsfml-graphics.so" "$PROJECT_ROOT/libsfml-graphics.so.2.5"
    ln -sf "$SFML_DIR/lib/libsfml-window.so" "$PROJECT_ROOT/libsfml-window.so.2.5"
    ln -sf "$SFML_DIR/lib/libsfml-system.so" "$PROJECT_ROOT/libsfml-system.so.2.5"
    
    echo "SFML установлен в $SFML_DIR"
}

# Установка шрифтов DejaVu
install_dejavu_fonts() {
    if [ -f "$PROJECT_ROOT/DejaVuSans.ttf" ]; then
        read -p "Шрифт DejaVuSans уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "Переустановка шрифта DejaVuSans..."
        else
            echo "Пропускаю установку шрифта DejaVuSans..."
            return
        fi
    fi
    
    echo "Установка шрифтов DejaVu..."
    cd "$PROJECT_ROOT"
    rm -rf "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37.tar.bz2"
    
    # Скачиваем и распаковываем шрифты
    wget -P "$DEJAVU_INSTALL_DIR/" https://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2
    tar -xjf "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37.tar.bz2" -C "$DEJAVU_INSTALL_DIR/"
    
    # Копируем шрифты в корень проекта
    cp "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37/ttf/DejaVuSans.ttf" "$PROJECT_ROOT/"
    
    echo "Шрифты DejaVu установлены в $PROJECT_ROOT"
}

# Создаем конфигурацию для библиотек
setup_env() {
    ENV_FILE="$PROJECT_ROOT/nibbler_env.sh"
    echo "Создание файла конфигурации окружения..."
    
    cat > "$ENV_FILE" << EOF
#!/bin/sh
# Конфигурация окружения для Nibbler

export LD_LIBRARY_PATH="$SDL_DIR/lib:$RAYLIB_DIR/lib:$SFML_DIR/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"

# Печать информации о настройке среды
echo "Переменные окружения настроены для Nibbler"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
EOF

    chmod +x "$ENV_FILE"
    echo "Файл конфигурации окружения создан: $ENV_FILE"
}

# Создаем скрипт запуска
create_run_script() {
    RUN_SCRIPT="$PROJECT_ROOT/run_nibbler.sh"
    echo "Создание скрипта запуска..."
    
    cat > "$RUN_SCRIPT" << EOF
#!/bin/sh
# Скрипт запуска Nibbler

SCRIPT_DIR="\$(dirname "\$(realpath "\$0")")"
source "\$SCRIPT_DIR/nibbler_env.sh"

# Проверка аргументов командной строки
if [ \$# -ne 2 ]; then
    echo "Использование: ./run_nibbler.sh <ширина> <высота>"
    echo "Пример: ./run_nibbler.sh 20 20"
    exit 1
fi

# Проверка значений аргументов
if [ \$1 -lt 10 ] || [ \$1 -gt 100 ] || [ \$2 -lt 10 ] || [ \$2 -gt 100 ]; then
    echo "Ошибка: Ширина и высота должны быть от 10 до 100"
    exit 1
fi

# Запуск Nibbler
echo "Запуск Nibbler с параметрами: \$1 x \$2"
"\$SCRIPT_DIR/nibbler" \$1 \$2
EOF

    chmod +x "$RUN_SCRIPT"
    echo "Скрипт запуска создан: $RUN_SCRIPT"
}

# Проверяем наличие библиотек и запрашиваем очистку
check_existing_libs

echo "Начинаем установку библиотек..."

# Запускаем установку всех компонентов
install_sdl2
install_sdl2_image
install_sdl2_ttf
install_raylib
install_sfml
install_dejavu_fonts
setup_env
create_run_script

echo "Все зависимости установлены. Структура директорий:"
echo "SDL2: $SDL_DIR"
echo "SFML: $SFML_DIR"
echo "Raylib: $RAYLIB_DIR"
echo "Шрифты: $DEJAVU_INSTALL_DIR"
echo ""
echo "Для сборки проекта выполните: make"
echo "Для запуска проекта выполните: ./run_nibbler.sh <ширина> <высота>"
echo "Пример: ./run_nibbler.sh 20 20" 