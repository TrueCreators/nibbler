#!/bin/bash

# Скрипт для установки всех зависимостей с учетом исправлений для Ubuntu 24.04

echo "Установка всех зависимостей для Nibbler в Ubuntu 24.04..."

# Получаем путь к корневой директории проекта
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

# Установка Raylib и SFML с фиксами
"$SCRIPT_DIR/install_dependencies_no_sudo.sh"

# Проверяем результаты установки
if [ ! -f "$PROJECT_ROOT/libraylib.so" ] || [ ! -f "$PROJECT_ROOT/libsfml-graphics.so.2.5" ]; then
    echo "Возникли проблемы при установке библиотек. Применяем исправления..."
    
    # Установка исправленного Raylib
    if [ ! -f "$PROJECT_ROOT/libraylib.so" ]; then
        echo "Устанавливаем Raylib с исправлениями..."
        "$SCRIPT_DIR/install_raylib_fix.sh"
    fi
    
    # Установка исправленного SFML
    if [ ! -f "$PROJECT_ROOT/libsfml-graphics.so.2.5" ] && [ ! -f "$PROJECT_ROOT/libsfml-graphics.so.2.4" ]; then
        echo "Устанавливаем SFML с исправлениями..."
        "$SCRIPT_DIR/install_sfml_fix.sh"
    fi
fi

# Создаем скрипт запуска с учетом возможных исправлений
echo "Создание исправленного скрипта запуска..."

cat > "$PROJECT_ROOT/run_nibbler_fixed.sh" << EOF
#!/bin/bash
# Скрипт запуска Nibbler для Ubuntu 24.04 с исправлениями

SCRIPT_DIR="\$(dirname "\$(realpath "\$0")")"
SDL_DIR="\$SCRIPT_DIR/libs/sdl"
SFML_DIR="\$SCRIPT_DIR/libs/sfml"
RAYLIB_DIR="\$SCRIPT_DIR/libs/raylib"

# Устанавливаем переменные окружения
export LD_LIBRARY_PATH="\$SDL_DIR/lib:\$RAYLIB_DIR/lib:\$SFML_DIR/lib:\$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="\$SDL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH"

# Печать информации о настройке среды
echo "Переменные окружения настроены для Nibbler в Ubuntu 24.04"
echo "LD_LIBRARY_PATH: \$LD_LIBRARY_PATH"

# Проверка аргументов командной строки
if [ \$# -ne 2 ]; then
    echo "Использование: ./run_nibbler_fixed.sh <ширина> <высота>"
    echo "Пример: ./run_nibbler_fixed.sh 20 20"
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

chmod +x "$PROJECT_ROOT/run_nibbler_fixed.sh"

# Создание скрипта для компиляции проекта
echo "Создание скрипта для компиляции проекта..."

cat > "$PROJECT_ROOT/build_nibbler.sh" << EOF
#!/bin/bash
# Скрипт для компиляции Nibbler в Ubuntu 24.04

SCRIPT_DIR="\$(dirname "\$(realpath "\$0")")"
SDL_DIR="\$SCRIPT_DIR/libs/sdl"
SFML_DIR="\$SCRIPT_DIR/libs/sfml"
RAYLIB_DIR="\$SCRIPT_DIR/libs/raylib"

# Устанавливаем переменные окружения
export LD_LIBRARY_PATH="\$SDL_DIR/lib:\$RAYLIB_DIR/lib:\$SFML_DIR/lib:\$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="\$SDL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH"

# Очистка сборки при необходимости
if [ "\$1" = "clean" ]; then
    echo "Очистка проекта..."
    make fclean
fi

# Компиляция проекта
echo "Компиляция проекта Nibbler..."
make -j\$(nproc)

if [ \$? -ne 0 ]; then
    echo "Ошибка при компиляции проекта!"
    exit 1
fi

echo "Проект успешно скомпилирован."
echo "Для запуска используйте: ./run_nibbler_fixed.sh <ширина> <высота>"
EOF

chmod +x "$PROJECT_ROOT/build_nibbler.sh"

echo "Все зависимости установлены, скрипты созданы."
echo ""
echo "Использование:"
echo "  ./build_nibbler.sh        - компиляция проекта"
echo "  ./build_nibbler.sh clean  - очистка и перекомпиляция проекта"
echo "  ./run_nibbler_fixed.sh 20 20 - запуск приложения с полем 20x20"
echo ""
echo "Если у вас возникнут проблемы, проверьте файлы:"
echo "  - raylib_install_log.txt  - лог установки Raylib"
echo "  - sfml_install_log.txt    - лог установки SFML"
echo "  - install_log.txt         - общий лог установки" 