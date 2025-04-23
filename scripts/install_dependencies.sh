#!/bin/sh

# Скрипт для установки всех необходимых зависимостей из исходных кодов без использования пакетных менеджеров

echo "Установка зависимостей для Nibbler..."

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
mkdir -p "$SFML_DIR/src"
mkdir -p "$RAYLIB_DIR/src"
mkdir -p "$DEJAVU_INSTALL_DIR"

# Проверка наличия библиотек и запрос на очистку
check_existing_libs() {
    local libs_exist=false
    local should_clean=false
    
    echo "Проверка наличия ранее установленных библиотек..."
    
    # Проверяем библиотеки SDL
    if [ -d "$SDL_DIR/lib" ] || [ -d "$SDL_DIR/include" ]; then
        echo "Обнаружены файлы SDL библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки SFML
    if [ -d "$SFML_DIR/lib" ] || [ -d "$SFML_DIR/include" ]; then
        echo "Обнаружены файлы SFML библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки Raylib
    if [ -d "$RAYLIB_DIR/lib" ] || [ -d "$RAYLIB_DIR/include" ]; then
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

# Проверяем наличие библиотек и запрашиваем очистку
check_existing_libs

echo "Начинаем установку библиотек..."

# Функция для компиляции и установки SDL2
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
    rm -rf src/SDL2-2.0.22.tar.gz
    
    # Скачиваем исходники SDL2
    wget -P src/ https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
    tar -xzf src/SDL2-2.0.22.tar.gz -C src/
    cd src/SDL2-2.0.22
    
    # Конфигурируем и компилируем
    ./configure --prefix="$SDL_DIR"
    make -j4
    make install
    
    # Создаем симлинк для библиотеки
    ln -sf "$SDL_DIR/lib/libSDL2.so" "$PROJECT_ROOT/libSDL2-2.0.so.0"
    
    echo "SDL2 установлен в $SDL_DIR"
}

# Функция для компиляции и установки SDL2_image
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
    rm -rf src/SDL2_image-2.0.5.tar.gz
    
    # Скачиваем исходники SDL2_image
    wget -P src/ https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
    tar -xzf src/SDL2_image-2.0.5.tar.gz -C src/
    cd src/SDL2_image-2.0.5
    
    # Конфигурируем и компилируем
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR"
    make -j4
    make install
    echo "SDL2_image установлен в $SDL_DIR"
}

# Функция для компиляции и установки SDL2_ttf
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
    rm -rf src/SDL2_ttf-2.0.18.tar.gz
    
    # Скачиваем исходники SDL2_ttf
    wget -P src/ https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.18.tar.gz
    tar -xzf src/SDL2_ttf-2.0.18.tar.gz -C src/
    cd src/SDL2_ttf-2.0.18
    
    # Конфигурируем и компилируем
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR"
    make -j4
    make install
    echo "SDL2_ttf установлен в $SDL_DIR"
}

# Функция для компиляции и установки Raylib
install_raylib() {
    if [ -f "$RAYLIB_DIR/lib/raylib.so" ] && [ -f "$RAYLIB_DIR/include/raylib.h" ]; then
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
    echo "Компиляция raylib.so..."
    gcc -shared -DPLATFORM_DESKTOP -o raylib.so \
        -fPIC \
        *.c \
        -lGL -lm -lpthread -ldl -lrt -lX11
    
    # Копируем библиотеки и заголовочные файлы
    mkdir -p "$RAYLIB_DIR/include"
    mkdir -p "$RAYLIB_DIR/lib"
    cp raylib.so "$RAYLIB_DIR/lib/"
    cp raylib.h "$RAYLIB_DIR/include/"
    cp raymath.h "$RAYLIB_DIR/include/"
    cp rlgl.h "$RAYLIB_DIR/include/"
    
    # Копируем библиотеку напрямую в корневую директорию
    cp -f "$RAYLIB_DIR/lib/raylib.so" "$PROJECT_ROOT/"
    
    echo "Raylib установлен в $RAYLIB_DIR"
}

# Функция для компиляции и установки SFML
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
    make -j4
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

# Обновляем Makefile для использования локальных библиотек
update_makefiles() {
    echo "Обновление Makefile..."
    
    # Обновляем Makefile для SDL
    SDL_MAKEFILE="$SDL_DIR/Makefile"
    if [ -f "$SDL_MAKEFILE" ]; then
        sed -i "s|-I/usr/include/SDL2|-I$SDL_DIR/include/SDL2|g" "$SDL_MAKEFILE"
        sed -i "s|LIBS = -lSDL2 -lSDL2_image -lSDL2_ttf|LIBS = -L$SDL_DIR/lib -lSDL2 -lSDL2_image -lSDL2_ttf|g" "$SDL_MAKEFILE"
    fi
    
    # Обновляем Makefile для SFML
    SFML_MAKEFILE="$SFML_DIR/Makefile"
    if [ -f "$SFML_MAKEFILE" ]; then
        sed -i "s|LIBS = -lsfml-graphics -lsfml-window -lsfml-system|LIBS = -L$SFML_DIR/lib -lsfml-graphics -lsfml-window -lsfml-system|g" "$SFML_MAKEFILE"
    fi
    
    # Обновляем Makefile для Raylib
    RAYLIB_MAKEFILE="$RAYLIB_DIR/Makefile"
    if [ -f "$RAYLIB_MAKEFILE" ]; then
        sed -i "s|LIBS = -lraylib -lGL -lm -lpthread -ldl -lrt -lX11|LIBS = -L$RAYLIB_DIR/lib -lraylib -lGL -lm -lpthread -ldl -lrt -lX11|g" "$RAYLIB_MAKEFILE"
    fi
    
    echo "Makefiles обновлены."
}

# Компиляция библиотек с помощью Makefile
compile_libs() {
    echo "Компиляция библиотек с использованием Makefile..."
    
    # Компилируем SDL библиотеку
    if [ -f "$SDL_DIR/Makefile" ]; then
        echo "Компиляция SDL библиотеки..."
        cd "$SDL_DIR"
        make
    fi
    
    # Компилируем SFML библиотеку
    if [ -f "$SFML_DIR/Makefile" ]; then
        echo "Компиляция SFML библиотеки..."
        cd "$SFML_DIR"
        make
    fi
    
    # Компилируем Raylib библиотеку
    if [ -f "$RAYLIB_DIR/Makefile" ]; then
        echo "Компиляция Raylib библиотеки..."
        cd "$RAYLIB_DIR"
        make
    fi
    
    echo "Все библиотеки скомпилированы."
}

# Запускаем установку всех компонентов
install_sdl2
install_sdl2_image
install_sdl2_ttf
install_raylib
install_sfml
install_dejavu_fonts
update_makefiles
compile_libs

echo "Все зависимости установлены. Структура директорий:"
echo "SDL2: $SDL_DIR"
echo "SFML: $SFML_DIR"
echo "Raylib: $RAYLIB_DIR"
echo "Шрифты: $DEJAVU_INSTALL_DIR"
echo "Все символические ссылки на библиотеки созданы в корне проекта." 