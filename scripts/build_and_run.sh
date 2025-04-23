#!/bin/sh

# Скрипт для сборки и запуска проекта Nibbler

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

# Проверка наличия файла настроек окружения
if [ ! -f "$PROJECT_ROOT/nibbler_env.sh" ]; then
    echo "Ошибка: Не найден файл настроек окружения (nibbler_env.sh)"
    echo "Пожалуйста, сначала запустите скрипт install_dependencies_no_sudo.sh"
    exit 1
fi

# Загрузка настроек окружения
source "$PROJECT_ROOT/nibbler_env.sh"

# Функция сборки проекта
build_project() {
    echo "Сборка проекта Nibbler..."
    cd "$PROJECT_ROOT"
    
    # Очистка предыдущей сборки
    if [ "$1" = "clean" ]; then
        echo "Очистка предыдущей сборки..."
        make fclean
    fi
    
    # Сборка проекта
    make -j$(nproc)
    
    if [ $? -ne 0 ]; then
        echo "Ошибка при сборке проекта"
        exit 1
    fi
    
    echo "Проект успешно собран"
}

# Функция запуска проекта
run_project() {
    # Проверка наличия исполняемого файла
    if [ ! -f "$PROJECT_ROOT/nibbler" ]; then
        echo "Ошибка: Исполняемый файл nibbler не найден"
        echo "Попробуйте собрать проект заново"
        exit 1
    fi
    
    # Проверка аргументов командной строки
    if [ $# -lt 2 ]; then
        echo "Недостаточно аргументов для запуска"
        echo "Использование: $0 [clean] <ширина> <высота>"
        echo "Значения по умолчанию: ширина = 20, высота = 20"
        WIDTH=20
        HEIGHT=20
    else
        WIDTH=$1
        HEIGHT=$2
    fi
    
    # Проверка значений аргументов
    if [ $WIDTH -lt 10 ] || [ $WIDTH -gt 100 ] || [ $HEIGHT -lt 10 ] || [ $HEIGHT -gt 100 ]; then
        echo "Ошибка: Ширина и высота должны быть от 10 до 100"
        exit 1
    fi
    
    # Запуск Nibbler
    echo "Запуск Nibbler с параметрами: $WIDTH x $HEIGHT"
    cd "$PROJECT_ROOT"
    ./nibbler $WIDTH $HEIGHT
}

# Обработка аргументов командной строки
if [ "$1" = "clean" ]; then
    build_project clean
    if [ $# -ge 3 ]; then
        run_project $2 $3
    else
        echo "Проект собран. Для запуска используйте: $0 <ширина> <высота>"
    fi
elif [ "$1" = "run" ]; then
    if [ $# -ge 3 ]; then
        run_project $2 $3
    else
        run_project 20 20
    fi
elif [ "$1" = "build" ]; then
    build_project
else
    echo "Использование скрипта:"
    echo "$0 build        - Сборка проекта"
    echo "$0 clean        - Очистка и пересборка проекта"
    echo "$0 run [w] [h]  - Запуск проекта (по умолчанию 20x20)"
    echo "$0 clean [w] [h]- Очистка, пересборка и запуск проекта"
    echo ""
    echo "Примеры:"
    echo "$0 run 30 30    - Запуск с полем 30x30"
    echo "$0 clean 15 15  - Очистка, пересборка и запуск с полем 15x15"
fi 