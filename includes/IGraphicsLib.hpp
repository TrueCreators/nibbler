#ifndef IGRAPHICSLIB_HPP
#define IGRAPHICSLIB_HPP

#include <string>

enum class Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
};

enum class KeyPress {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    ONE,
    TWO,
    THREE,
    ESC,
    RESTART,
    ENTER,
    MOUSE_LEFT,
    NONE
};

// Перечисление для состояний меню
enum class MenuState {
    MAIN_MENU,
    SINGLE_PLAYER_MENU,
    MULTIPLAYER_MENU,
    SETTINGS_MENU,
    GAME_OVER,
    PAUSE,
    GAME_RUNNING,
    EXIT
};

// Перечисление для типов игры
enum class GameMode {
    CLASSIC,          // Обычный режим
    DYNAMIC_SPEED,    // Нарастающая скорость
    SNACK_SPRINT,     // Убегающая еда
    SURVIVAL,         // Выживание
    CONTINUE          // Продолжить игру
};

class IGraphicsLib {
public:
    virtual ~IGraphicsLib() {}

    // Инициализация библиотеки с размером окна
    virtual bool init(int width, int height, const std::string &title) = 0;

    // Закрытие/очистка библиотеки
    virtual void cleanup() = 0;

    // Отрисовка змейки (координаты x, y и направление)
    virtual void drawSnake(int x, int y, Direction dir) = 0;

    // Отрисовка секции тела змейки
    virtual void drawSnakeSection(int x, int y) = 0;

    // Отрисовка еды на поле
    virtual void drawFood(int x, int y) = 0;

    // Отрисовка стены/границы
    virtual void drawWall(int x, int y) = 0;

    // Очистка экрана перед отрисовкой нового кадра
    virtual void clearScreen() = 0;

    // Обновление экрана после отрисовки
    virtual void updateScreen() = 0;

    // Получение нажатий клавиш
    virtual KeyPress getInput() = 0;

    // Проверка, открыто ли окно
    virtual bool isWindowOpen() = 0;

    // Установка задержки между кадрами (мс)
    virtual void setFrameDelay(int ms) = 0;
    
    // Новые методы для работы с меню
    
    // Отрисовка текста
    virtual void drawText(const std::string &text, int x, int y, int fontSize, bool isCentered = false) = 0;
    
    // Отрисовка кнопки (возвращает true, если на кнопку наведен курсор)
    virtual bool drawButton(const std::string &text, int x, int y, int width, int height, bool isSelected = false, int fontSize = 20) = 0;
    
    // Получение позиции мыши
    virtual void getMousePosition(int &x, int &y) = 0;
    
    // Отрисовка фона меню
    virtual void drawMenuBackground() = 0;

    // Методы для получения размеров окна и ячейки
    virtual int getWindowWidth() const = 0;
    virtual int getWindowHeight() const = 0;
    virtual int getCellSize() const = 0;
    virtual int getGridWidth() const = 0;  // Количество ячеек по ширине
    virtual int getGridHeight() const = 0;  // Количество ячеек по высоте
};

// Функции для создания и удаления экземпляра графической библиотеки
// (должны быть реализованы в каждой библиотеке с extern "C")
extern "C" {
    typedef IGraphicsLib* create_t();
    typedef void destroy_t(IGraphicsLib*);
}

#endif // IGRAPHICSLIB_HPP 