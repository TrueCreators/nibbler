#ifndef GAME_HPP
#define GAME_HPP

#include <string>
#include <vector>
#include "Snake.hpp"
#include "Food.hpp"
#include "DynamicLoader.hpp"
#include "Menu.hpp"
#include "IGraphicsLib.hpp"
#include <deque>

enum class GameState {
    MENU,       // Состояние меню
    RUNNING,    // Игра активна
    PAUSED,     // Игра на паузе
    GAME_OVER,  // Игра окончена
    EXIT        // Выход из игры
};

// Структура для сохранения состояния игры
struct GameSnapshot {
    std::deque<Position> snakeBody;
    Direction snakeDirection;
    Position foodPosition;
    int score;
    int speed;
    GameMode gameMode;
};

class Game {
private:
    int _width;
    int _height;
    int _speed;
    GameState _state;
    GameMode _gameMode;
    
    Snake *_snake;
    Food *_food;
    DynamicLoader _libLoader;
    Menu _menu;
    
    std::vector<std::string> _libPaths;
    size_t _currentLibIndex;
    
    GameSnapshot* _savedState;  // Указатель на сохраненное состояние
    
    // Инициализация игры
    void init();
    
    // Обработка ввода игрока
    void handleInput();
    
    // Обновление игрового состояния
    void update();
    
    // Отрисовка игрового состояния
    void render();
    
    // Отрисовка меню
    void renderMenu();
    
    // Обработка ввода меню
    void handleMenuInput(KeyPress key);
    
    // Смена библиотеки
    bool switchLibrary(size_t index);
    
    // Обновление игры в зависимости от выбранного режима
    void updateGameMode();
    
    bool saveGameState();     // Изменено с void на bool
    void restoreGameState();  // Новый метод для восстановления состояния
    
    void handleStateSpecificInput(KeyPress key);
    
public:
    Game(int width, int height, const std::vector<std::string> &libPaths);
    ~Game();
    
    // Основной игровой цикл
    void run();
    
    // Перезапуск игры
    void restart();
    
    // Получение текущего состояния игры
    GameState getState() const;
};

#endif // GAME_HPP 