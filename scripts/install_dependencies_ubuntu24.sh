#!/bin/bash

# Скрипт для установки всех необходимых зависимостей из исходных кодов без использования sudo
# Специальная версия для Ubuntu 24.04

echo "Установка зависимостей для Nibbler в Ubuntu 24.04 без прав администратора..."

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

# Логирование и обработка ошибок
LOG_FILE="$PROJECT_ROOT/install_log.txt"
touch "$LOG_FILE"

log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "ОШИБКА: $1" | tee -a "$LOG_FILE"
}

handle_error() {
    if [ $? -ne 0 ]; then
        log_error "$1"
        log_error "Проверьте файл лога: $LOG_FILE для получения подробной информации."
        return 1
    fi
    return 0
}

# Проверка наличия библиотек и запрос на очистку
check_existing_libs() {
    local libs_exist=false
    local should_clean=false
    
    log_message "Проверка наличия ранее установленных библиотек..."
    
    # Проверяем библиотеки SDL
    if [ -d "$SDL_DIR/lib" ] && [ "$(ls -A "$SDL_DIR/lib" 2>/dev/null)" ]; then
        log_message "Обнаружены файлы SDL библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки SFML
    if [ -d "$SFML_DIR/lib" ] && [ "$(ls -A "$SFML_DIR/lib" 2>/dev/null)" ]; then
        log_message "Обнаружены файлы SFML библиотеки"
        libs_exist=true
    fi
    
    # Проверяем библиотеки Raylib
    if [ -d "$RAYLIB_DIR/lib" ] && [ "$(ls -A "$RAYLIB_DIR/lib" 2>/dev/null)" ]; then
        log_message "Обнаружены файлы Raylib библиотеки"
        libs_exist=true
    fi
    
    if $libs_exist; then
        read -p "Обнаружены ранее установленные библиотеки. Очистить перед установкой новых? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            should_clean=true
        else
            log_message "Продолжаю установку без очистки..."
        fi
    fi
    
    if $should_clean; then
        clean_libs
    fi
}

# Очищаем предыдущие установки
clean_libs() {
    log_message "Очистка предыдущих установок..."
    
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
    
    log_message "Предыдущие установки очищены."
}

# Проверка и установка системных пакетов для сборки
check_build_deps() {
    log_message "Проверка необходимых системных зависимостей..."
    
    # Проверка наличия базовых утилит и инструментов
    for cmd in gcc g++ make cmake wget git tar pkg-config; do
        if ! command -v $cmd &> /dev/null; then
            log_error "Не найдена команда: $cmd"
            log_error "Пожалуйста, установите базовые инструменты разработки:"
            log_error "sudo apt-get install build-essential cmake git wget pkg-config"
            return 1
        fi
    done
    
    # Проверка наличия библиотек разработки
    log_message "Рекомендуемые библиотеки для разработки (не обязательно, если библиотеки устанавливаются из исходников):"
    log_message "SDL2: libsdl2-dev, libsdl2-image-dev, libsdl2-ttf-dev"
    log_message "SFML зависимости: libx11-dev, libxrandr-dev, libxcursor-dev, libudev-dev, libopenal-dev, libflac-dev, libvorbis-dev, libgl1-mesa-dev"
    log_message "Raylib зависимости: libasound2-dev, libx11-dev, libxrandr-dev, libxi-dev, libgl1-mesa-dev, libglu1-mesa-dev"
    
    return 0
}

# Функция для установки SDL2
install_sdl2() {
    if [ -f "$SDL_DIR/lib/libSDL2.so" ] && [ -d "$SDL_DIR/include/SDL2" ]; then
        read -p "SDL2 уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка SDL2..."
        else
            log_message "Пропускаю установку SDL2..."
            return 0
        fi
    fi

    log_message "Установка SDL2 из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2-2.0.22.tar.gz src/SDL2-2.0.22
    
    # Скачиваем исходники SDL2
    log_message "Скачивание SDL2-2.0.22.tar.gz..."
    wget -P src/ https://www.libsdl.org/release/SDL2-2.0.22.tar.gz >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при скачивании SDL2" || return 1
    
    tar -xzf src/SDL2-2.0.22.tar.gz -C src/ >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при распаковке SDL2" || return 1
    
    cd src/SDL2-2.0.22
    
    # Конфигурируем и компилируем
    log_message "Конфигурация SDL2..."
    ./configure --prefix="$SDL_DIR" >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации SDL2" || return 1
    
    log_message "Компиляция SDL2..."
    make -j$(nproc) >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при компиляции SDL2" || return 1
    
    log_message "Установка SDL2..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке SDL2" || return 1
    
    # Создаем симлинк для библиотеки
    ln -sf "$SDL_DIR/lib/libSDL2.so" "$PROJECT_ROOT/libSDL2-2.0.so.0"
    
    log_message "SDL2 успешно установлен в $SDL_DIR"
    return 0
}

# Функция для установки SDL2_image
install_sdl2_image() {
    if [ -f "$SDL_DIR/lib/libSDL2_image.so" ]; then
        read -p "SDL2_image уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка SDL2_image..."
        else
            log_message "Пропускаю установку SDL2_image..."
            return 0
        fi
    fi
    
    log_message "Установка SDL2_image из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2_image-2.0.5.tar.gz src/SDL2_image-2.0.5
    
    # Скачиваем исходники SDL2_image
    log_message "Скачивание SDL2_image-2.0.5.tar.gz..."
    wget -P src/ https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при скачивании SDL2_image" || return 1
    
    tar -xzf src/SDL2_image-2.0.5.tar.gz -C src/ >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при распаковке SDL2_image" || return 1
    
    cd src/SDL2_image-2.0.5
    
    # Конфигурируем и компилируем
    log_message "Конфигурация SDL2_image..."
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR" >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации SDL2_image" || return 1
    
    log_message "Компиляция SDL2_image..."
    make -j$(nproc) >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при компиляции SDL2_image" || return 1
    
    log_message "Установка SDL2_image..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке SDL2_image" || return 1
    
    log_message "SDL2_image успешно установлен в $SDL_DIR"
    return 0
}

# Функция для установки SDL2_ttf
install_sdl2_ttf() {
    if [ -f "$SDL_DIR/lib/libSDL2_ttf.so" ]; then
        read -p "SDL2_ttf уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка SDL2_ttf..."
        else
            log_message "Пропускаю установку SDL2_ttf..."
            return 0
        fi
    fi
    
    log_message "Установка SDL2_ttf из исходников..."
    cd "$SDL_DIR"
    rm -rf src/SDL2_ttf-2.0.18.tar.gz src/SDL2_ttf-2.0.18
    
    # Скачиваем исходники SDL2_ttf
    log_message "Скачивание SDL2_ttf-2.0.18.tar.gz..."
    wget -P src/ https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.18.tar.gz >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при скачивании SDL2_ttf" || return 1
    
    tar -xzf src/SDL2_ttf-2.0.18.tar.gz -C src/ >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при распаковке SDL2_ttf" || return 1
    
    cd src/SDL2_ttf-2.0.18
    
    # Конфигурируем и компилируем
    log_message "Конфигурация SDL2_ttf..."
    PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig" ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR" >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации SDL2_ttf" || return 1
    
    log_message "Компиляция SDL2_ttf..."
    make -j$(nproc) >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при компиляции SDL2_ttf" || return 1
    
    log_message "Установка SDL2_ttf..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке SDL2_ttf" || return 1
    
    log_message "SDL2_ttf успешно установлен в $SDL_DIR"
    return 0
}

# Функция для установки SFML для Ubuntu 24.04
install_sfml() {
    if [ -f "$SFML_DIR/lib/libsfml-graphics.so" ] && [ -d "$SFML_DIR/include/SFML" ]; then
        read -p "SFML уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка SFML..."
        else
            log_message "Пропускаю установку SFML..."
            return 0
        fi
    fi
    
    log_message "Установка SFML из исходников (специальная версия для Ubuntu 24.04)..."
    cd "$SFML_DIR"
    rm -rf src/SFML
    
    # Клонируем репозиторий SFML
    log_message "Клонирование репозитория SFML 2.5.1..."
    git clone https://github.com/SFML/SFML.git src/SFML --branch 2.5.1 --depth 1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при клонировании репозитория SFML" || return 1
    
    # Создаем директорию для сборки
    mkdir -p src/SFML/build
    cd src/SFML/build
    
    # Устанавливаем дополнительные флаги для Ubuntu 24.04
    export CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0"
    
    # Компилируем SFML
    log_message "Конфигурация SFML с CMake..."
    cmake -DCMAKE_INSTALL_PREFIX="$SFML_DIR" \
          -DBUILD_SHARED_LIBS=TRUE \
          -DSFML_USE_SYSTEM_DEPS=FALSE \
          -DCMAKE_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
          -DCMAKE_BUILD_TYPE=Release \
          .. >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации SFML" || return 1
    
    log_message "Компиляция SFML..."
    make -j$(nproc) VERBOSE=1 >> "$LOG_FILE" 2>&1
    
    # Проверяем результат компиляции
    if [ $? -ne 0 ]; then
        log_error "Ошибка при компиляции SFML. Попытка компиляции с альтернативными настройками..."
        
        # Попробуем альтернативный метод сборки, если первый не удался
        cd "$SFML_DIR"
        rm -rf src/SFML
        
        log_message "Клонирование репозитория SFML 2.5.0..."
        git clone https://github.com/SFML/SFML.git src/SFML --branch 2.5.0 --depth 1 >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при клонировании репозитория SFML 2.5.0" || return 1
        
        mkdir -p src/SFML/build
        cd src/SFML/build
        
        log_message "Конфигурация SFML 2.5.0 с CMake..."
        cmake -DCMAKE_INSTALL_PREFIX="$SFML_DIR" \
              -DBUILD_SHARED_LIBS=TRUE \
              -DSFML_USE_SYSTEM_DEPS=FALSE \
              -DCMAKE_BUILD_TYPE=Release \
              .. >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при альтернативной конфигурации SFML" || return 1
        
        log_message "Компиляция SFML 2.5.0..."
        make -j$(nproc) >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при альтернативной компиляции SFML" || return 1
    fi
    
    log_message "Установка SFML..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке SFML" || return 1
    
    # Создаем симлинки для библиотек
    ln -sf "$SFML_DIR/lib/libsfml-graphics.so" "$PROJECT_ROOT/libsfml-graphics.so.2.5"
    ln -sf "$SFML_DIR/lib/libsfml-window.so" "$PROJECT_ROOT/libsfml-window.so.2.5"
    ln -sf "$SFML_DIR/lib/libsfml-system.so" "$PROJECT_ROOT/libsfml-system.so.2.5"
    
    log_message "SFML успешно установлен в $SFML_DIR"
    return 0
}

# Функция для установки Raylib для Ubuntu 24.04
install_raylib() {
    if [ -f "$RAYLIB_DIR/lib/libraylib.so" ] && [ -f "$RAYLIB_DIR/include/raylib.h" ]; then
        read -p "Raylib уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка Raylib..."
        else
            log_message "Пропускаю установку Raylib..."
            return 0
        fi
    fi
    
    log_message "Установка Raylib из исходников (специальная версия для Ubuntu 24.04)..."
    cd "$RAYLIB_DIR"
    rm -rf src/raylib
    
    # Клонируем репозиторий Raylib
    log_message "Клонирование репозитория Raylib..."
    git clone https://github.com/raysan5/raylib.git src/raylib --branch '4.5.0' --depth 1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при клонировании репозитория Raylib" || return 1
    
    # Создаем директорию для сборки с CMake
    mkdir -p src/raylib/build
    cd src/raylib/build
    
    # Компилируем Raylib с CMake
    log_message "Конфигурация Raylib с CMake..."
    cmake -DCMAKE_INSTALL_PREFIX="$RAYLIB_DIR" \
          -DBUILD_SHARED_LIBS=ON \
          -DCMAKE_BUILD_TYPE=Release \
          -DUSE_EXTERNAL_GLFW=OFF \
          .. >> "$LOG_FILE" 2>&1
    
    # Проверяем результат конфигурации
    if [ $? -ne 0 ]; then
        log_error "Ошибка при конфигурации Raylib с CMake. Попытка компиляции вручную..."
        
        # Пробуем альтернативный метод компиляции
        cd "$RAYLIB_DIR/src/raylib/src"
        
        log_message "Компиляция Raylib вручную..."
        gcc -shared -DPLATFORM_DESKTOP -o libraylib.so \
            -fPIC \
            *.c \
            -lGL -lm -lpthread -ldl -lrt -lX11 >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при ручной компиляции Raylib" || return 1
        
        # Копируем библиотеки и заголовочные файлы
        mkdir -p "$RAYLIB_DIR/include"
        mkdir -p "$RAYLIB_DIR/lib"
        cp libraylib.so "$RAYLIB_DIR/lib/"
        cp raylib.h "$RAYLIB_DIR/include/"
        cp raymath.h "$RAYLIB_DIR/include/"
        cp rlgl.h "$RAYLIB_DIR/include/"
    else
        # Продолжаем сборку с CMake, если конфигурация прошла успешно
        log_message "Компиляция Raylib..."
        make -j$(nproc) >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при компиляции Raylib" || return 1
        
        log_message "Установка Raylib..."
        make install >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при установке Raylib" || return 1
    fi
    
    # Создаем симлинк в корневой директории
    ln -sf "$RAYLIB_DIR/lib/libraylib.so" "$PROJECT_ROOT/libraylib.so"
    
    log_message "Raylib успешно установлен в $RAYLIB_DIR"
    return 0
}

# Установка шрифтов DejaVu
install_dejavu_fonts() {
    if [ -f "$PROJECT_ROOT/DejaVuSans.ttf" ]; then
        read -p "Шрифт DejaVuSans уже установлен. Переустановить? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            log_message "Переустановка шрифта DejaVuSans..."
        else
            log_message "Пропускаю установку шрифта DejaVuSans..."
            return 0
        fi
    fi
    
    log_message "Установка шрифтов DejaVu..."
    cd "$PROJECT_ROOT"
    rm -rf "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37.tar.bz2"
    
    # Скачиваем и распаковываем шрифты
    log_message "Скачивание dejavu-fonts-ttf-2.37.tar.bz2..."
    wget -P "$DEJAVU_INSTALL_DIR/" https://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при скачивании шрифтов DejaVu" || return 1
    
    tar -xjf "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37.tar.bz2" -C "$DEJAVU_INSTALL_DIR/" >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при распаковке шрифтов DejaVu" || return 1
    
    # Копируем шрифты в корень проекта
    cp "$DEJAVU_INSTALL_DIR/dejavu-fonts-ttf-2.37/ttf/DejaVuSans.ttf" "$PROJECT_ROOT/"
    
    log_message "Шрифты DejaVu успешно установлены в $PROJECT_ROOT"
    return 0
}

# Создаем конфигурацию для библиотек
setup_env() {
    ENV_FILE="$PROJECT_ROOT/nibbler_env.sh"
    log_message "Создание файла конфигурации окружения..."
    
    cat > "$ENV_FILE" << EOF
#!/bin/bash
# Конфигурация окружения для Nibbler в Ubuntu 24.04

export LD_LIBRARY_PATH="$SDL_DIR/lib:$RAYLIB_DIR/lib:$SFML_DIR/lib:\$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$SDL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH"

# Печать информации о настройке среды
echo "Переменные окружения настроены для Nibbler в Ubuntu 24.04"
echo "LD_LIBRARY_PATH: \$LD_LIBRARY_PATH"
EOF

    chmod +x "$ENV_FILE"
    log_message "Файл конфигурации окружения создан: $ENV_FILE"
}

# Создаем скрипт запуска
create_run_script() {
    RUN_SCRIPT="$PROJECT_ROOT/run_nibbler.sh"
    log_message "Создание скрипта запуска..."
    
    cat > "$RUN_SCRIPT" << EOF
#!/bin/bash
# Скрипт запуска Nibbler для Ubuntu 24.04

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
    log_message "Скрипт запуска создан: $RUN_SCRIPT"
}

# Проверяем наличие необходимых системных зависимостей
check_build_deps || exit 1

# Проверяем наличие библиотек и запрашиваем очистку
check_existing_libs

log_message "Начинаем установку библиотек для Ubuntu 24.04..."

# Запускаем установку всех компонентов
install_sdl2
install_sdl2_image
install_sdl2_ttf
install_sfml
install_raylib
install_dejavu_fonts
setup_env
create_run_script

log_message "Все зависимости установлены для Ubuntu 24.04. Структура директорий:"
log_message "SDL2: $SDL_DIR"
log_message "SFML: $SFML_DIR"
log_message "Raylib: $RAYLIB_DIR"
log_message "Шрифты: $DEJAVU_INSTALL_DIR"
log_message ""
log_message "Лог установки сохранен в: $LOG_FILE"
log_message ""
log_message "Для сборки проекта выполните: make"
log_message "Для запуска проекта выполните: ./run_nibbler.sh <ширина> <высота>"
log_message "Пример: ./run_nibbler.sh 20 20" 