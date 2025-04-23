#!/bin/bash

# Скрипт для установки GLFW и Raylib в локальной директории проекта
# Без использования sudo, все библиотеки устанавливаются в libs/

echo "Установка GLFW и Raylib для Nibbler..."

# Получаем путь к корневой директории проекта
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
GLFW_DIR="$PROJECT_ROOT/libs/glfw"
RAYLIB_DIR="$PROJECT_ROOT/libs/raylib"

# Создаем директории, если они не существуют
mkdir -p "$GLFW_DIR/src"
mkdir -p "$GLFW_DIR/lib"
mkdir -p "$GLFW_DIR/include"
mkdir -p "$RAYLIB_DIR/src"
mkdir -p "$RAYLIB_DIR/lib"
mkdir -p "$RAYLIB_DIR/include"

# Логирование и обработка ошибок
LOG_FILE="$PROJECT_ROOT/glfw_raylib_install_log.txt"
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

# Функция для установки зависимостей для сборки GLFW
install_deps() {
    log_message "Проверка наличия необходимых инструментов для сборки..."
    
    local missing_tools=()
    
    # Проверка основных инструментов
    for tool in gcc g++ make cmake git wget pkg-config; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Отсутствуют необходимые инструменты: ${missing_tools[*]}"
        log_error "Установите их командой: sudo apt-get install ${missing_tools[*]}"
        return 1
    fi
    
    return 0
}

# Функция для установки GLFW
install_glfw() {
    log_message "Установка GLFW из исходников..."
    cd "$GLFW_DIR"
    rm -rf src/glfw
    
    # Клонируем репозиторий GLFW
    log_message "Клонирование репозитория GLFW 3.3.8 (стабильная версия)..."
    git clone https://github.com/glfw/glfw.git src/glfw --branch 3.3.8 --depth 1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при клонировании репозитория GLFW" || return 1
    
    # Создаем директорию для сборки
    mkdir -p src/glfw/build
    cd src/glfw/build
    
    # Компилируем GLFW
    log_message "Конфигурация GLFW с CMake..."
    cmake -DCMAKE_INSTALL_PREFIX="$GLFW_DIR" \
          -DBUILD_SHARED_LIBS=ON \
          -DGLFW_BUILD_EXAMPLES=OFF \
          -DGLFW_BUILD_TESTS=OFF \
          -DGLFW_BUILD_DOCS=OFF \
          .. >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации GLFW" || return 1
    
    log_message "Компиляция GLFW..."
    make -j$(nproc) >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при компиляции GLFW" || return 1
    
    log_message "Установка GLFW..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке GLFW" || return 1
    
    # Создаем симлинк
    ln -sf "$GLFW_DIR/lib/libglfw.so.3" "$PROJECT_ROOT/libglfw.so.3"
    
    log_message "GLFW успешно установлен в $GLFW_DIR"
    return 0
}

# Функция для установки Raylib с использованием установленного GLFW
install_raylib() {
    log_message "Установка Raylib из исходников с использованием установленного GLFW..."
    cd "$RAYLIB_DIR"
    rm -rf src/raylib
    
    # Клонируем репозиторий Raylib (стабильная версия)
    log_message "Клонирование репозитория Raylib 4.5.0..."
    git clone https://github.com/raysan5/raylib.git src/raylib --branch '4.5.0' --depth 1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при клонировании репозитория Raylib" || return 1
    
    # Создаем директорию для сборки
    mkdir -p src/raylib/build
    cd src/raylib/build
    
    # Настраиваем сборку Raylib с использованием нашего GLFW
    log_message "Конфигурация Raylib с CMake, используя установленный GLFW..."
    
    # Устанавливаем переменные окружения для CMake
    export PKG_CONFIG_PATH="$GLFW_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    cmake -DCMAKE_INSTALL_PREFIX="$RAYLIB_DIR" \
          -DBUILD_SHARED_LIBS=ON \
          -DUSE_EXTERNAL_GLFW=ON \
          -DGLFW_INCLUDE_DIRS="$GLFW_DIR/include" \
          -DGLFW_LIBRARY="$GLFW_DIR/lib/libglfw.so" \
          -DCMAKE_BUILD_TYPE=Release \
          -DPLATFORM=Desktop \
          .. >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при конфигурации Raylib" || return 1
    
    log_message "Компиляция Raylib..."
    make -j$(nproc) VERBOSE=1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при компиляции Raylib" || return 1
    
    log_message "Установка Raylib..."
    make install >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при установке Raylib" || return 1
    
    # Создаем симлинк
    ln -sf "$RAYLIB_DIR/lib/libraylib.so" "$PROJECT_ROOT/libraylib.so"
    
    log_message "Raylib успешно установлен в $RAYLIB_DIR"
    return 0
}

# Альтернативная функция установки Raylib вручную с GLFW
install_raylib_manual() {
    log_message "Ручная установка Raylib со ссылкой на установленный GLFW..."
    cd "$RAYLIB_DIR"
    rm -rf src/raylib
    
    # Клонируем репозиторий Raylib (более старая, но стабильная версия)
    log_message "Клонирование репозитория Raylib 3.0.0 (совместимая версия)..."
    git clone https://github.com/raysan5/raylib.git src/raylib --branch '3.0.0' --depth 1 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при клонировании репозитория Raylib" || return 1
    
    cd src/raylib/src
    
    # Создаем файл конфигурации для использования внешнего GLFW
    log_message "Настройка использования внешнего GLFW..."
    cat > config.h << EOF
#define PLATFORM_DESKTOP
#define GRAPHICS_API_OPENGL_33
#define SUPPORT_FILEFORMAT_JPG
#define SUPPORT_FILEFORMAT_PNG
#define SUPPORT_FILEFORMAT_BMP
#define SUPPORT_FILEFORMAT_TGA
#define SUPPORT_FILEFORMAT_GIF
#define SUPPORT_MESH_GENERATION
#define SUPPORT_DEFAULT_FONT
#define SUPPORT_EXTERNAL_GLFW
EOF
    
    # Компилируем исходники Raylib в shared library
    log_message "Компиляция Raylib с использованием внешнего GLFW..."
    
    # Список исходных файлов
    SRC_FILES="raudio.c rcore.c rmodels.c rshapes.c rtext.c rtextures.c utils.c"
    OBJ_FILES=""
    
    # Компилируем каждый исходный файл
    for src in $SRC_FILES; do
        obj=${src%.c}.o
        OBJ_FILES="$OBJ_FILES $obj"
        
        gcc -c -fPIC -O2 -Wall -DPLATFORM_DESKTOP -DSUPPORT_EXTERNAL_GLFW -I. -I"$GLFW_DIR/include" $src -o $obj >> "$LOG_FILE" 2>&1
        handle_error "Ошибка при компиляции $src" || return 1
    done
    
    # Линкуем объектные файлы в библиотеку
    log_message "Линковка libraylib.so..."
    gcc -shared -o libraylib.so $OBJ_FILES -L"$GLFW_DIR/lib" -lglfw -lGL -lm -lpthread -ldl -lrt -lX11 >> "$LOG_FILE" 2>&1
    handle_error "Ошибка при линковке libraylib.so" || return 1
    
    # Копируем библиотеки и заголовочные файлы
    mkdir -p "$RAYLIB_DIR/include"
    mkdir -p "$RAYLIB_DIR/lib"
    
    cp libraylib.so "$RAYLIB_DIR/lib/"
    cp raylib.h "$RAYLIB_DIR/include/"
    cp raymath.h "$RAYLIB_DIR/include/"
    cp rlgl.h "$RAYLIB_DIR/include/"
    
    # Создаем симлинк в корневой директории
    ln -sf "$RAYLIB_DIR/lib/libraylib.so" "$PROJECT_ROOT/libraylib.so"
    
    log_message "Raylib успешно установлен вручную в $RAYLIB_DIR"
    return 0
}

# Основной скрипт
log_message "Начинаем установку GLFW и Raylib..."

# Проверяем наличие необходимых инструментов
install_deps || exit 1

# Устанавливаем GLFW
install_glfw || exit 1

# Устанавливаем Raylib, используя установленный GLFW
install_raylib || {
    log_message "Возникли проблемы при установке Raylib через CMake, пробуем ручную установку..."
    install_raylib_manual || exit 1
}

# Устанавливаем переменные окружения для запуска Nibbler
log_message "Создание файла окружения для запуска Nibbler..."

cat > "$PROJECT_ROOT/raylib_env.sh" << EOF
#!/bin/bash
# Переменные окружения для запуска Nibbler с установленным Raylib

export LD_LIBRARY_PATH="$GLFW_DIR/lib:$RAYLIB_DIR/lib:\$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$GLFW_DIR/lib/pkgconfig:$RAYLIB_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH"

echo "Переменные окружения настроены для Raylib"
echo "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH"
echo "PKG_CONFIG_PATH=\$PKG_CONFIG_PATH"

# Запуск приложения с аргументами
if [ \$# -gt 0 ]; then
    "\$PROJECT_ROOT/\$@"
fi
EOF

chmod +x "$PROJECT_ROOT/raylib_env.sh"

log_message "Установка GLFW и Raylib успешно завершена!"
echo "GLFW установлен в $GLFW_DIR"
echo "Raylib установлен в $RAYLIB_DIR"
echo "Для запуска приложения используйте скрипт: $PROJECT_ROOT/raylib_env.sh nibbler 20 20"
echo ""
echo "Подробный лог установки: $LOG_FILE"

exit 0 