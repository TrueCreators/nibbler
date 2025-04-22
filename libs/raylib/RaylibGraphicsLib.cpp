#include "RaylibGraphicsLib.hpp"
#include <iostream>

RaylibGraphicsLib::RaylibGraphicsLib()
    : _width(0), _height(0), _cellSize(20), _frameDelay(100), _windowOpen(false), _fontLoaded(false) {
    
    // Инициализация цветов
    _backgroundColor = BLACK;
    _snakeColor = GREEN;
    _foodColor = RED;
    _wallColor = GRAY;
    _menuBackgroundColor = (Color){ 20, 20, 50, 255 }; // Темно-синий
    _buttonColor = (Color){ 70, 70, 120, 255 }; // Темно-фиолетовый
    _buttonHoverColor = (Color){ 100, 100, 180, 255 }; // Светло-фиолетовый
    _buttonSelectedColor = (Color){ 120, 120, 220, 255 }; // Ярко-фиолетовый
    _textColor = WHITE;
    
    // Инициализация позиции мыши
    _mousePosition = (Vector2){ 0.0f, 0.0f };
}

RaylibGraphicsLib::~RaylibGraphicsLib() {
    cleanup();
}

bool RaylibGraphicsLib::init(int width, int height, const std::string &title) {
    _width = width;
    _height = height;
    
    // Инициализация окна Raylib
    InitWindow(_width * _cellSize, _height * _cellSize, title.c_str());
    SetTargetFPS(60);
    
    // Отключаем автоматическое закрытие окна по ESC
    SetExitKey(KEY_NULL);
    
    // Загрузка шрифта
    std::cout << "Пытаюсь загрузить шрифт из /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf для Raylib..." << std::endl;
    _font = LoadFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf");
    _fontLoaded = _font.texture.id > 0;
    
    if (!_fontLoaded) {
        std::cerr << "Ошибка загрузки шрифта из системного пути для Raylib" << std::endl;
        
        // Пробуем загрузить из локальной директории
        std::cout << "Пытаюсь загрузить шрифт из текущей директории для Raylib..." << std::endl;
        _font = LoadFont("DejaVuSans.ttf");
        _fontLoaded = _font.texture.id > 0;
        
        if (!_fontLoaded) {
            std::cerr << "Ошибка загрузки шрифта из текущей директории для Raylib" << std::endl;
        } else {
            std::cout << "Шрифт успешно загружен из текущей директории для Raylib" << std::endl;
        }
    } else {
        std::cout << "Шрифт успешно загружен из системной директории для Raylib" << std::endl;
    }
    
    _windowOpen = true;
    return true;
}

void RaylibGraphicsLib::cleanup() {
    if (_fontLoaded) {
        UnloadFont(_font);
        _fontLoaded = false;
    }
    
    if (_windowOpen) {
        CloseWindow();
        _windowOpen = false;
    }
}

void RaylibGraphicsLib::drawSnake(int x, int y, Direction dir) {
    // Рисуем голову змейки как прямоугольник
    DrawRectangle(x * _cellSize, y * _cellSize, _cellSize, _cellSize, _snakeColor);
    
    // Добавляем глаза в зависимости от направления
    Color eyeColor = WHITE;
    int eyeSize = _cellSize / 5;
    
    // Расположение глаз зависит от направления
    switch (dir) {
        case Direction::UP:
            DrawRectangle(x * _cellSize + _cellSize / 4, y * _cellSize + _cellSize / 4, eyeSize, eyeSize, eyeColor);
            DrawRectangle(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4, eyeSize, eyeSize, eyeColor);
            break;
        case Direction::DOWN:
            DrawRectangle(x * _cellSize + _cellSize / 4, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize, eyeColor);
            DrawRectangle(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize, eyeColor);
            break;
        case Direction::LEFT:
            DrawRectangle(x * _cellSize + _cellSize / 4, y * _cellSize + _cellSize / 4, eyeSize, eyeSize, eyeColor);
            DrawRectangle(x * _cellSize + _cellSize / 4, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize, eyeColor);
            break;
        case Direction::RIGHT:
            DrawRectangle(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4, eyeSize, eyeSize, eyeColor);
            DrawRectangle(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize, eyeColor);
            break;
    }
}

void RaylibGraphicsLib::drawSnakeSection(int x, int y) {
    // Рисуем секцию тела змейки как прямоугольник
    DrawRectangle(x * _cellSize + 1, y * _cellSize + 1, _cellSize - 2, _cellSize - 2, _snakeColor);
}

void RaylibGraphicsLib::drawFood(int x, int y) {
    // Рисуем еду как круг
    DrawCircle(x * _cellSize + _cellSize / 2, y * _cellSize + _cellSize / 2, _cellSize / 2 - 2, _foodColor);
}

void RaylibGraphicsLib::drawWall(int x, int y) {
    // Рисуем стену как прямоугольник
    DrawRectangle(x * _cellSize, y * _cellSize, _cellSize, _cellSize, _wallColor);
}

void RaylibGraphicsLib::clearScreen() {
    if (!_windowOpen) {
        return;
    }
    
    BeginDrawing();
    ClearBackground(_backgroundColor);
}

void RaylibGraphicsLib::updateScreen() {
    if (!_windowOpen) {
        return;
    }
    
    EndDrawing();
    
    // Задержка для контроля скорости
    if (_frameDelay > 0) {
        WaitTime(_frameDelay / 1000.0f);
    }
}

KeyPress RaylibGraphicsLib::getInput() {
    // Обновляем позицию мыши
    _mousePosition = GetMousePosition();
    
    // Проверяем нажатия клавиш
    if (IsKeyPressed(KEY_UP)) {
        return KeyPress::UP;
    }
    if (IsKeyPressed(KEY_DOWN)) {
        return KeyPress::DOWN;
    }
    if (IsKeyPressed(KEY_LEFT)) {
        return KeyPress::LEFT;
    }
    if (IsKeyPressed(KEY_RIGHT)) {
        return KeyPress::RIGHT;
    }
    if (IsKeyPressed(KEY_ONE) || IsKeyPressed(KEY_KP_1)) {
        return KeyPress::ONE;
    }
    if (IsKeyPressed(KEY_TWO) || IsKeyPressed(KEY_KP_2)) {
        return KeyPress::TWO;
    }
    if (IsKeyPressed(KEY_THREE) || IsKeyPressed(KEY_KP_3)) {
        return KeyPress::THREE;
    }
    if (IsKeyPressed(KEY_R)) {
        return KeyPress::RESTART;
    }
    if (IsKeyPressed(KEY_ENTER)) {
        return KeyPress::ENTER;
    }
    if (IsKeyPressed(KEY_ESCAPE)) {
        return KeyPress::ESC;
    }
    
    // Проверяем нажатие кнопки мыши
    if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
        return KeyPress::MOUSE_LEFT;
    }
    
    // Проверяем только кнопку закрытия окна, игнорируя ESC
    if (WindowShouldClose() && !IsKeyPressed(KEY_ESCAPE)) {
        _windowOpen = false;
    }
    
    return KeyPress::NONE;
}

bool RaylibGraphicsLib::isWindowOpen() {
    return _windowOpen;
}

void RaylibGraphicsLib::setFrameDelay(int ms) {
    _frameDelay = ms;
}

void RaylibGraphicsLib::drawText(const std::string &text, int x, int y, int fontSize, bool isCentered) {
    // Определяем размеры текста
    Vector2 textSize = MeasureTextEx(_fontLoaded ? _font : GetFontDefault(), text.c_str(), fontSize, 1.0f);
    
    // Вычисляем позицию для отрисовки
    float posX = isCentered ? x - textSize.x / 2.0f : x;
    
    // Рисуем текст
    if (_fontLoaded) {
        DrawTextEx(_font, text.c_str(), (Vector2){ posX, (float)y }, fontSize, 1.0f, _textColor);
    } else {
        DrawText(text.c_str(), posX, y, fontSize, _textColor);
    }
}

bool RaylibGraphicsLib::drawButton(const std::string &text, int x, int y, int width, int height, bool isSelected, int fontSize) {
    // Получаем позицию мыши
    Vector2 mousePos = GetMousePosition();
    bool isHovered = CheckCollisionPointRec(mousePos, {(float)x, (float)y, (float)width, (float)height});
    
    // Выбираем цвет в зависимости от состояния кнопки
    Color buttonColor = isSelected || isHovered ? GRAY : DARKGRAY;
    
    // Рисуем кнопку
    DrawRectangle(x, y, width, height, buttonColor);
    DrawRectangleLines(x, y, width, height, WHITE);
    
    // Рисуем текст по центру кнопки
    int textWidth = MeasureText(text.c_str(), fontSize);
    int textX = x + (width - textWidth) / 2;
    int textY = y + (height - fontSize) / 2;
    DrawText(text.c_str(), textX, textY, fontSize, WHITE);
    
    return isHovered;
}

void RaylibGraphicsLib::getMousePosition(int &x, int &y) {
    x = (int)_mousePosition.x;
    y = (int)_mousePosition.y;
}

void RaylibGraphicsLib::drawMenuBackground() {
    // Очищаем экран цветом фона меню
    ClearBackground(_menuBackgroundColor);
    
    // Рисуем декоративную сетку
    for (int i = 0; i < _width * _cellSize; i += 40) {
        DrawLine(i, 0, i, _height * _cellSize, (Color){ 40, 40, 80, 255 });
    }
    
    for (int i = 0; i < _height * _cellSize; i += 40) {
        DrawLine(0, i, _width * _cellSize, i, (Color){ 40, 40, 80, 255 });
    }
}

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create() {
        return new RaylibGraphicsLib();
    }
    
    void destroy(IGraphicsLib* instance) {
        delete instance;
    }
} 