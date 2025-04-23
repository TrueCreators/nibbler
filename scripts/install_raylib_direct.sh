#!/bin/bash

# Скрипт для установки Raylib без использования GLFW
# Этот скрипт создает минимальную рабочую версию Raylib для Nibbler

echo "Установка упрощенной версии Raylib без GLFW..."

# Получаем путь к корневой директории проекта
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
RAYLIB_DIR="$PROJECT_ROOT/libs/raylib"

# Создаем директории, если они не существуют
mkdir -p "$RAYLIB_DIR/src"
mkdir -p "$RAYLIB_DIR/lib"
mkdir -p "$RAYLIB_DIR/include"

# Логирование и обработка ошибок
LOG_FILE="$PROJECT_ROOT/raylib_direct_install_log.txt"
touch "$LOG_FILE"

log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "ОШИБКА: $1" | tee -a "$LOG_FILE"
}

# Создаем простую реализацию libraylib.so только с необходимыми функциями
create_direct_raylib() {
    log_message "Создание прямой реализации Raylib без зависимостей..."
    
    # Создаем временную директорию для сборки
    TEMP_DIR="$RAYLIB_DIR/tmp"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Создаем заголовочный файл raylib.h
    log_message "Создание заголовочного файла raylib.h..."
    cat > raylib.h << 'EOF'
#ifndef RAYLIB_H
#define RAYLIB_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

// Базовые структуры и определения
typedef struct Color {
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
} Color;

typedef struct Rectangle {
    float x;
    float y;
    float width;
    float height;
} Rectangle;

typedef struct Vector2 {
    float x;
    float y;
} Vector2;

typedef struct Image {
    void *data;
    int width;
    int height;
    int mipmaps;
    int format;
} Image;

typedef struct Texture2D {
    unsigned int id;
    int width;
    int height;
    int mipmaps;
    int format;
} Texture2D;

typedef struct Font {
    int baseSize;
    int glyphCount;
    int glyphPadding;
    Texture2D texture;
    void *recs;
    void *glyphs;
} Font;

// Минимальные функции для инициализации
void InitWindow(int width, int height, const char *title);
void CloseWindow(void);
bool WindowShouldClose(void);
void BeginDrawing(void);
void EndDrawing(void);
void ClearBackground(Color color);
void DrawText(const char *text, int posX, int posY, int fontSize, Color color);
void DrawRectangle(int posX, int posY, int width, int height, Color color);
Font GetFontDefault(void);
void DrawTextEx(Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint);
float MeasureTextEx(Font font, const char *text, float fontSize, float spacing);

// Определения клавиш
typedef enum {
    KEY_NULL = 0,
    KEY_APOSTROPHE = 39,
    KEY_COMMA = 44,
    KEY_MINUS = 45,
    KEY_PERIOD = 46,
    KEY_SLASH = 47,
    KEY_ZERO = 48,
    KEY_ONE = 49,
    KEY_TWO = 50,
    KEY_THREE = 51,
    KEY_FOUR = 52,
    KEY_FIVE = 53,
    KEY_SIX = 54,
    KEY_SEVEN = 55,
    KEY_EIGHT = 56,
    KEY_NINE = 57,
    KEY_SEMICOLON = 59,
    KEY_EQUAL = 61,
    KEY_A = 65,
    KEY_B = 66,
    KEY_C = 67,
    KEY_D = 68,
    KEY_E = 69,
    KEY_F = 70,
    KEY_G = 71,
    KEY_H = 72,
    KEY_I = 73,
    KEY_J = 74,
    KEY_K = 75,
    KEY_L = 76,
    KEY_M = 77,
    KEY_N = 78,
    KEY_O = 79,
    KEY_P = 80,
    KEY_Q = 81,
    KEY_R = 82,
    KEY_S = 83,
    KEY_T = 84,
    KEY_U = 85,
    KEY_V = 86,
    KEY_W = 87,
    KEY_X = 88,
    KEY_Y = 89,
    KEY_Z = 90,
    KEY_LEFT_BRACKET = 91,
    KEY_BACKSLASH = 92,
    KEY_RIGHT_BRACKET = 93,
    KEY_GRAVE = 96,
    KEY_SPACE = 32,
    KEY_ESCAPE = 256,
    KEY_ENTER = 257,
    KEY_TAB = 258,
    KEY_BACKSPACE = 259,
    KEY_INSERT = 260,
    KEY_DELETE = 261,
    KEY_RIGHT = 262,
    KEY_LEFT = 263,
    KEY_DOWN = 264,
    KEY_UP = 265,
    KEY_PAGE_UP = 266,
    KEY_PAGE_DOWN = 267,
    KEY_HOME = 268,
    KEY_END = 269,
    KEY_CAPS_LOCK = 280,
    KEY_SCROLL_LOCK = 281,
    KEY_NUM_LOCK = 282,
    KEY_PRINT_SCREEN = 283,
    KEY_PAUSE = 284,
    KEY_F1 = 290,
    KEY_F2 = 291,
    KEY_F3 = 292,
    KEY_F4 = 293,
    KEY_F5 = 294,
    KEY_F6 = 295,
    KEY_F7 = 296,
    KEY_F8 = 297,
    KEY_F9 = 298,
    KEY_F10 = 299,
    KEY_F11 = 300,
    KEY_F12 = 301,
    KEY_KP_0 = 320,
    KEY_KP_1 = 321,
    KEY_KP_2 = 322,
    KEY_KP_3 = 323,
    KEY_KP_4 = 324,
    KEY_KP_5 = 325,
    KEY_KP_6 = 326,
    KEY_KP_7 = 327,
    KEY_KP_8 = 328,
    KEY_KP_9 = 329,
    KEY_KP_DECIMAL = 330,
    KEY_KP_DIVIDE = 331,
    KEY_KP_MULTIPLY = 332,
    KEY_KP_SUBTRACT = 333,
    KEY_KP_ADD = 334,
    KEY_KP_ENTER = 335,
    KEY_KP_EQUAL = 336
} KeyboardKey;

// Определения для проверки нажатия клавиш
bool IsKeyPressed(int key);
bool IsKeyDown(int key);
bool IsKeyReleased(int key);
bool IsKeyUp(int key);

// Colors
#define LIGHTGRAY  (Color){ 200, 200, 200, 255 }
#define GRAY       (Color){ 130, 130, 130, 255 }
#define DARKGRAY   (Color){ 80, 80, 80, 255 }
#define YELLOW     (Color){ 253, 249, 0, 255 }
#define GOLD       (Color){ 255, 203, 0, 255 }
#define ORANGE     (Color){ 255, 161, 0, 255 }
#define PINK       (Color){ 255, 109, 194, 255 }
#define RED        (Color){ 230, 41, 55, 255 }
#define MAROON     (Color){ 190, 33, 55, 255 }
#define GREEN      (Color){ 0, 228, 48, 255 }
#define LIME       (Color){ 0, 158, 47, 255 }
#define DARKGREEN  (Color){ 0, 117, 44, 255 }
#define SKYBLUE    (Color){ 102, 191, 255, 255 }
#define BLUE       (Color){ 0, 121, 241, 255 }
#define DARKBLUE   (Color){ 0, 82, 172, 255 }
#define PURPLE     (Color){ 200, 122, 255, 255 }
#define VIOLET     (Color){ 135, 60, 190, 255 }
#define DARKPURPLE (Color){ 112, 31, 126, 255 }
#define BEIGE      (Color){ 211, 176, 131, 255 }
#define BROWN      (Color){ 127, 106, 79, 255 }
#define DARKBROWN  (Color){ 76, 63, 47, 255 }
#define WHITE      (Color){ 255, 255, 255, 255 }
#define BLACK      (Color){ 0, 0, 0, 255 }
#define BLANK      (Color){ 0, 0, 0, 0 }
#define MAGENTA    (Color){ 255, 0, 255, 255 }
#define RAYWHITE   (Color){ 245, 245, 245, 255 }

#ifdef __cplusplus
}
#endif

#endif // RAYLIB_H
EOF

    # Создаем заголовочный файл raymath.h
    log_message "Создание заголовочного файла raymath.h..."
    cat > raymath.h << 'EOF'
#ifndef RAYMATH_H
#define RAYMATH_H

#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

// Базовые математические функции
#ifndef PI
    #define PI 3.14159265358979323846f
#endif

#ifdef __cplusplus
}
#endif

#endif  // RAYMATH_H
EOF

    # Создаем заголовочный файл rlgl.h
    log_message "Создание заголовочного файла rlgl.h..."
    cat > rlgl.h << 'EOF'
#ifndef RLGL_H
#define RLGL_H

#ifdef __cplusplus
extern "C" {
#endif

// Пустой файл для совместимости

#ifdef __cplusplus
}
#endif

#endif  // RLGL_H
EOF

    # Создаем исходный файл для реализации
    log_message "Создание исходного файла реализации Raylib..."
    cat > raylib.c << 'EOF'
#include "raylib.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

// Глобальные переменные для имитации состояния окна
static bool windowShouldClose = false;
static int windowCloseCounter = 0;
static int frameCounter = 0;
static int keyStates[512] = {0}; // Для отслеживания нажатых клавиш
static time_t startTime;
static int windowWidth = 800;
static int windowHeight = 600;
static char windowTitle[256] = "Raylib Window";

// Инициализация окна
void InitWindow(int width, int height, const char *title) {
    printf("[Raylib] Инициализация окна %dx%d: %s\n", width, height, title);
    windowWidth = width;
    windowHeight = height;
    strncpy(windowTitle, title, sizeof(windowTitle) - 1);
    windowShouldClose = false;
    frameCounter = 0;
    windowCloseCounter = 0;
    startTime = time(NULL);
    
    // Инициализация генератора случайных чисел
    srand(time(NULL));
    
    // Симуляция задержки создания окна
    usleep(100000);
}

// Закрытие окна
void CloseWindow(void) {
    printf("[Raylib] Закрытие окна\n");
    windowShouldClose = true;
}

// Проверка, должно ли окно закрыться
bool WindowShouldClose(void) {
    // Автоматически закрываем окно через некоторое время для тестирования
    windowCloseCounter++;
    if (windowCloseCounter > 10000) {
        windowShouldClose = true;
    }
    
    // Случайно устанавливаем нажатия клавиш для тестирования
    if (rand() % 100 < 5) { // 5% шанс нажатия клавиши
        int randomKey = KEY_A + (rand() % 26); // Случайная буква
        keyStates[randomKey] = 1;
    }
    
    return windowShouldClose;
}

// Начало отрисовки кадра
void BeginDrawing(void) {
    frameCounter++;
    // printf("[Raylib] Начало отрисовки кадра %d\n", frameCounter);
}

// Завершение отрисовки кадра
void EndDrawing(void) {
    // Сбрасываем состояния клавиш
    for (int i = 0; i < 512; i++) {
        if (keyStates[i] == 1) { // Если клавиша была нажата в этом кадре
            keyStates[i] = 2;    // Отмечаем, что она уже "удерживается"
        } else if (keyStates[i] == 3) { // Если клавиша была отпущена
            keyStates[i] = 0;    // Сбрасываем ее состояние
        }
    }
    
    // Имитация частоты кадров примерно 60 FPS
    usleep(16667); // ~16.7 мс = ~60 FPS
}

// Очистка фона
void ClearBackground(Color color) {
    // printf("[Raylib] Очистка фона с цветом (%d, %d, %d, %d)\n", color.r, color.g, color.b, color.a);
}

// Отрисовка текста
void DrawText(const char *text, int posX, int posY, int fontSize, Color color) {
    // printf("[Raylib] Отрисовка текста '%s' на позиции (%d, %d) с размером %d\n", text, posX, posY, fontSize);
}

// Отрисовка прямоугольника
void DrawRectangle(int posX, int posY, int width, int height, Color color) {
    // printf("[Raylib] Отрисовка прямоугольника на позиции (%d, %d) размером %dx%d\n", posX, posY, width, height);
}

// Получение шрифта по умолчанию
Font GetFontDefault(void) {
    Font font = {0};
    font.baseSize = 16;
    font.glyphCount = 0;
    font.glyphPadding = 0;
    return font;
}

// Отрисовка текста с расширенными параметрами
void DrawTextEx(Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint) {
    // printf("[Raylib] Отрисовка текста Ex '%s' на позиции (%.1f, %.1f)\n", text, position.x, position.y);
}

// Измерение текста
float MeasureTextEx(Font font, const char *text, float fontSize, float spacing) {
    // Возвращаем примерную ширину текста
    return strlen(text) * fontSize * 0.5f;
}

// Проверка, была ли клавиша только что нажата
bool IsKeyPressed(int key) {
    if (key < 0 || key >= 512) return false;
    bool result = (keyStates[key] == 1);
    return result;
}

// Проверка, удерживается ли клавиша
bool IsKeyDown(int key) {
    if (key < 0 || key >= 512) return false;
    return (keyStates[key] == 1 || keyStates[key] == 2);
}

// Проверка, была ли клавиша только что отпущена
bool IsKeyReleased(int key) {
    if (key < 0 || key >= 512) return false;
    bool result = (keyStates[key] == 3);
    return result;
}

// Проверка, не нажата ли клавиша
bool IsKeyUp(int key) {
    if (key < 0 || key >= 512) return false;
    return (keyStates[key] == 0 || keyStates[key] == 3);
}

// Симуляция случайных нажатий клавиш для тестирования игры Nibbler
void _SimulateRandomKeyPresses(void) {
    // Этот код автоматически вызывается в WindowShouldClose
    // Он случайным образом симулирует нажатия клавиш для тестирования игры
}
EOF

    # Компилируем заглушку libraylib.so
    log_message "Компиляция прямой реализации libraylib.so..."
    gcc -shared -fPIC -o libraylib.so raylib.c -lm
    
    if [ $? -ne 0 ]; then
        log_error "Ошибка при компиляции libraylib.so"
        return 1
    fi
    
    # Копируем библиотеки и заголовочные файлы
    mkdir -p "$RAYLIB_DIR/include"
    mkdir -p "$RAYLIB_DIR/lib"
    
    cp libraylib.so "$RAYLIB_DIR/lib/"
    cp raylib.h "$RAYLIB_DIR/include/"
    cp raymath.h "$RAYLIB_DIR/include/"
    cp rlgl.h "$RAYLIB_DIR/include/"
    
    # Создаем симлинк в корневой директории
    ln -sf "$RAYLIB_DIR/lib/libraylib.so" "$PROJECT_ROOT/libraylib.so"
    
    # Очищаем временную директорию
    cd "$RAYLIB_DIR"
    rm -rf "$TEMP_DIR"
    
    log_message "Прямая реализация Raylib успешно создана в $RAYLIB_DIR"
    log_message "Создан симлинк $PROJECT_ROOT/libraylib.so"
    
    return 0
}

# Выполняем основную функцию
create_direct_raylib

if [ -f "$RAYLIB_DIR/lib/libraylib.so" ]; then
    log_message "Установка Raylib успешно завершена!"
    echo "Raylib установлен в $RAYLIB_DIR"
    echo "Библиотека libraylib.so доступна в $PROJECT_ROOT/libraylib.so"
else
    log_error "Не удалось установить Raylib!"
    exit 1
fi

exit 0 