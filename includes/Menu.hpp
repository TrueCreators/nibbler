#ifndef MENU_HPP
#define MENU_HPP

#include "IGraphicsLib.hpp"
#include <string>
#include <vector>
#include <functional>

// Структура для представления пункта меню
struct MenuItem {
    std::string text;
    std::function<void()> action; 
    bool isSelected;
    int x, y, width, height;

    MenuItem(const std::string &t, std::function<void()> a)
        : text(t), action(a), isSelected(false), x(0), y(0), width(0), height(0) {}
};

class Menu {
private:
    MenuState _currentState;
    GameMode _selectedGameMode;
    
    // Пункты меню для каждого состояния
    std::vector<MenuItem> _mainMenuItems;
    std::vector<MenuItem> _singlePlayerMenuItems;
    std::vector<MenuItem> _multiplayerMenuItems;
    std::vector<MenuItem> _settingsMenuItems;
    std::vector<MenuItem> _gameOverMenuItems;
    std::vector<MenuItem> _pauseMenuItems;
    
    // Указатели на активные пункты меню
    std::vector<MenuItem> *_activeMenuItems;
    size_t _selectedItemIndex;
    
    // Заголовки для каждого меню
    std::string _mainMenuTitle;
    std::string _singlePlayerMenuTitle;
    std::string _multiplayerMenuTitle;
    std::string _settingsMenuTitle;
    std::string _gameOverMenuTitle;
    std::string _pauseMenuTitle;
    
    // Функции для инициализации пунктов меню
    void initMainMenu();
    void initSinglePlayerMenu();
    void initMultiplayerMenu();
    void initSettingsMenu();
    void initGameOverMenu();
    void initPauseMenu();
    
    // Обработка ввода для активного меню
    void handleInput(KeyPress key, int mouseX, int mouseY);
    
    // Обновление выбранного пункта меню
    void updateSelectedMenuItem(int mouseX, int mouseY);
    
    // Переключение меню
    void switchToMenu(MenuState newState);
    
public:
    Menu();
    ~Menu() = default;
    
    // Инициализация меню
    void init();
    
    // Отрисовка текущего меню
    void render(IGraphicsLib *lib);
    
    // Обработка ввода
    void processInput(KeyPress key, IGraphicsLib *lib);
    
    // Получение текущего состояния меню
    MenuState getCurrentState() const;
    
    // Получение выбранного режима игры
    GameMode getSelectedGameMode() const;
    
    // Установка состояния игры после окончания раунда
    void setGameOver();
    
    // Установка состояния паузы
    void setPause();
};

#endif // MENU_HPP 