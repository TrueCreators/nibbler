#include "../includes/Menu.hpp"
#include <iostream>

Menu::Menu()
    : _currentState(MenuState::MAIN_MENU), 
      _selectedGameMode(GameMode::CLASSIC), 
      _activeMenuItems(nullptr),
      _selectedItemIndex(0) {
    
    // Initialize menu titles
    _mainMenuTitle = "NIBBLER";
    _singlePlayerMenuTitle = "Game Mode";
    _multiplayerMenuTitle = "Multiplayer";
    _settingsMenuTitle = "Settings";
    _gameOverMenuTitle = "GAME OVER";
    _pauseMenuTitle = "PAUSE";
    
    // Initialize menu items
    init();
}

void Menu::init() {
    // Инициализация различных меню
    initMainMenu();
    initSinglePlayerMenu();
    initMultiplayerMenu();
    initSettingsMenu();
    initGameOverMenu();
    initPauseMenu();
    
    // Устанавливаем начальное меню
    switchToMenu(MenuState::MAIN_MENU);
}

void Menu::initMainMenu() {
    _mainMenuItems.clear();
    
    // Add main menu items
    _mainMenuItems.push_back(MenuItem("Single Player", [this]() { 
        switchToMenu(MenuState::SINGLE_PLAYER_MENU); 
    }));
    
    _mainMenuItems.push_back(MenuItem("Multiplayer", [this]() { 
        switchToMenu(MenuState::MULTIPLAYER_MENU); 
    }));
    
    _mainMenuItems.push_back(MenuItem("Settings", [this]() { 
        switchToMenu(MenuState::SETTINGS_MENU); 
    }));
    
    _mainMenuItems.push_back(MenuItem("Exit", [this]() { 
        _currentState = MenuState::EXIT; 
    }));
}

void Menu::initSinglePlayerMenu() {
    _singlePlayerMenuItems.clear();
    
    // Single player game modes
    _singlePlayerMenuItems.push_back(MenuItem("Classic Mode", [this]() {
        _selectedGameMode = GameMode::CLASSIC;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _singlePlayerMenuItems.push_back(MenuItem("Dynamic Speed", [this]() {
        _selectedGameMode = GameMode::DYNAMIC_SPEED;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _singlePlayerMenuItems.push_back(MenuItem("Snack Sprint", [this]() {
        _selectedGameMode = GameMode::SNACK_SPRINT;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _singlePlayerMenuItems.push_back(MenuItem("Survival Mode", [this]() {
        _selectedGameMode = GameMode::SURVIVAL;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _singlePlayerMenuItems.push_back(MenuItem("Back", [this]() { 
        switchToMenu(MenuState::MAIN_MENU); 
    }));
}

void Menu::initMultiplayerMenu() {
    _multiplayerMenuItems.clear();
    
    // Пункты меню мультиплеера
    _multiplayerMenuItems.push_back(MenuItem("Multiplayer Local (2 players)", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Multiplayer mode is not implemented yet" << std::endl;
    }));
    
    _multiplayerMenuItems.push_back(MenuItem("Create Session", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Network mode is not implemented yet" << std::endl;
    }));
    
    _multiplayerMenuItems.push_back(MenuItem("Find Session", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Network mode is not implemented yet" << std::endl;
    }));
    
    _multiplayerMenuItems.push_back(MenuItem("Back", [this]() { 
        switchToMenu(MenuState::MAIN_MENU); 
    }));
}

void Menu::initSettingsMenu() {
    _settingsMenuItems.clear();
    
    // Пункты меню настроек
    _settingsMenuItems.push_back(MenuItem("Sound Settings", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Sound settings are not implemented yet" << std::endl;
    }));
    
    _settingsMenuItems.push_back(MenuItem("Display Settings", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Display settings are not implemented yet" << std::endl;
    }));
    
    _settingsMenuItems.push_back(MenuItem("Language", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Language settings are not implemented yet" << std::endl;
    }));
    
    _settingsMenuItems.push_back(MenuItem("Controls", [this]() {
        // Пока заглушка - режим не реализован
        std::cout << "Control settings are not implemented yet" << std::endl;
    }));
    
    _settingsMenuItems.push_back(MenuItem("Back", [this]() { 
        switchToMenu(MenuState::MAIN_MENU); 
    }));
}

void Menu::initGameOverMenu() {
    _gameOverMenuItems.clear();
    
    // Game over menu items
    _gameOverMenuItems.push_back(MenuItem("New Game", [this]() { 
        _currentState = MenuState::GAME_RUNNING; 
    }));
    
    _gameOverMenuItems.push_back(MenuItem("Main Menu", [this]() { 
        switchToMenu(MenuState::MAIN_MENU); 
    }));
    
    _gameOverMenuItems.push_back(MenuItem("Exit", [this]() { 
        _currentState = MenuState::EXIT; 
    }));
}

void Menu::initPauseMenu() {
    _pauseMenuItems.clear();
    
    // Пункты меню паузы
    _pauseMenuItems.push_back(MenuItem("Continue", [this]() {
        _selectedGameMode = GameMode::CONTINUE;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _pauseMenuItems.push_back(MenuItem("New Game", [this]() {
        _selectedGameMode = GameMode::CLASSIC;
        _currentState = MenuState::GAME_RUNNING;
    }));
    
    _pauseMenuItems.push_back(MenuItem("Main Menu", [this]() { 
        switchToMenu(MenuState::MAIN_MENU); 
    }));
    
    _pauseMenuItems.push_back(MenuItem("Exit", [this]() { 
        _currentState = MenuState::EXIT; 
    }));
}

void Menu::switchToMenu(MenuState newState) {
    _currentState = newState;
    _selectedItemIndex = 0;
    
    // Обновляем указатель на активные пункты меню
    switch (newState) {
        case MenuState::MAIN_MENU:
            _activeMenuItems = &_mainMenuItems;
            break;
        case MenuState::SINGLE_PLAYER_MENU:
            _activeMenuItems = &_singlePlayerMenuItems;
            break;
        case MenuState::MULTIPLAYER_MENU:
            _activeMenuItems = &_multiplayerMenuItems;
            break;
        case MenuState::SETTINGS_MENU:
            _activeMenuItems = &_settingsMenuItems;
            break;
        case MenuState::GAME_OVER:
            _activeMenuItems = &_gameOverMenuItems;
            break;
        case MenuState::PAUSE:
            _activeMenuItems = &_pauseMenuItems;
            break;
        default:
            _activeMenuItems = nullptr;
            break;
    }
    
    // Устанавливаем первый пункт меню как выбранный
    if (_activeMenuItems && !_activeMenuItems->empty()) {
        for (size_t i = 0; i < _activeMenuItems->size(); ++i) {
            (*_activeMenuItems)[i].isSelected = (i == 0);
        }
    }
}

void Menu::render(IGraphicsLib *lib) {
    if (!lib || !_activeMenuItems) return;
    
    // Draw menu background
    lib->drawMenuBackground();
    
    // Get window and cell sizes
    int windowWidth = lib->getWindowWidth();
    int windowHeight = lib->getWindowHeight();
    int cellSize = lib->getCellSize();
    
    // Scale menu elements based on window size
    int buttonWidth = windowWidth / 3;
    int buttonHeight = cellSize * 2;
    int titleFontSize = cellSize * 2;
    int buttonFontSize = cellSize;
    
    // Get title based on current menu state
    std::string title;
    switch (_currentState) {
        case MenuState::MAIN_MENU:
            title = _mainMenuTitle;
            break;
        case MenuState::SINGLE_PLAYER_MENU:
            title = _singlePlayerMenuTitle;
            break;
        case MenuState::MULTIPLAYER_MENU:
            title = _multiplayerMenuTitle;
            break;
        case MenuState::SETTINGS_MENU:
            title = _settingsMenuTitle;
            break;
        case MenuState::GAME_OVER:
            title = _gameOverMenuTitle;
            break;
        case MenuState::PAUSE:
            title = _pauseMenuTitle;
            break;
        default:
            title = "";
            break;
    }
    
    // Draw menu title (centered at top)
    if (!title.empty()) {
        lib->drawText(title, windowWidth / 2, windowHeight / 6, titleFontSize, true);
    }
    
    // Show library switch hint
    std::string libText = "Press 1-3 to switch graphics library";
    lib->drawText(libText, windowWidth / 2, windowHeight / 4, buttonFontSize, true);
    
    // Calculate optimal button spacing
    int spacing = buttonHeight + cellSize;
    
    // Calculate initial position for first button
    int totalMenuHeight = spacing * (_activeMenuItems->size() - 1) + buttonHeight;
    int startY = (windowHeight - totalMenuHeight) / 2;
    
    // Center buttons horizontally
    int centerX = (windowWidth - buttonWidth) / 2;
    
    // Draw menu items
    for (size_t i = 0; i < _activeMenuItems->size(); ++i) {
        MenuItem &item = (*_activeMenuItems)[i];
        
        // Update button coordinates
        item.x = centerX;
        item.y = startY + i * spacing;
        item.width = buttonWidth;
        item.height = buttonHeight;
        
        // Draw button with scaled font size
        bool hover = lib->drawButton(item.text, item.x, item.y, item.width, item.height, item.isSelected, buttonFontSize);
        
        // If mouse is hovering over button, select it
        if (hover) {
            item.isSelected = true;
            _selectedItemIndex = i;
            
            // Deselect other buttons
            for (size_t j = 0; j < _activeMenuItems->size(); ++j) {
                if (j != i) {
                    (*_activeMenuItems)[j].isSelected = false;
                }
            }
        }
    }
}

void Menu::processInput(KeyPress key, IGraphicsLib *lib) {
    if (!lib) return;

    // Проверяем клавиши переключения библиотек
    if (key == KeyPress::ONE || key == KeyPress::TWO || key == KeyPress::THREE) {
        return;
    }

    // Получаем позицию мыши
    int mouseX, mouseY;
    lib->getMousePosition(mouseX, mouseY);
    
    // Обновляем выбранный пункт меню на основе позиции мыши
    updateSelectedMenuItem(mouseX, mouseY);
    
    // Обрабатываем ввод
    handleInput(key, mouseX, mouseY);
}

void Menu::updateSelectedMenuItem(int mouseX, int mouseY) {
    if (!_activeMenuItems) return;
    
    for (size_t i = 0; i < _activeMenuItems->size(); ++i) {
        MenuItem &item = (*_activeMenuItems)[i];
        
        // Проверяем, находится ли курсор над кнопкой
        if (mouseX >= item.x && mouseX <= item.x + item.width &&
            mouseY >= item.y && mouseY <= item.y + item.height) {
            
            // Если курсор над кнопкой, выделяем ее
            if (!item.isSelected) {
                item.isSelected = true;
                _selectedItemIndex = i;
                
                // Снимаем выделение с других кнопок
                for (size_t j = 0; j < _activeMenuItems->size(); ++j) {
                    if (j != i) {
                        (*_activeMenuItems)[j].isSelected = false;
                    }
                }
            }
            return;
        }
    }
}

void Menu::handleInput(KeyPress key, int mouseX, int mouseY) {
    if (!_activeMenuItems || _activeMenuItems->empty()) return;
    
    switch (key) {
        case KeyPress::UP:
            // Перемещение выделения вверх
            if (_selectedItemIndex > 0) {
                (*_activeMenuItems)[_selectedItemIndex].isSelected = false;
                _selectedItemIndex--;
                (*_activeMenuItems)[_selectedItemIndex].isSelected = true;
            }
            break;
            
        case KeyPress::DOWN:
            // Перемещение выделения вниз
            if (_selectedItemIndex < _activeMenuItems->size() - 1) {
                (*_activeMenuItems)[_selectedItemIndex].isSelected = false;
                _selectedItemIndex++;
                (*_activeMenuItems)[_selectedItemIndex].isSelected = true;
            }
            break;
            
        case KeyPress::ENTER:
            // Активация выбранного пункта меню
            if (_selectedItemIndex < _activeMenuItems->size()) {
                (*_activeMenuItems)[_selectedItemIndex].action();
            }
            break;
            
        case KeyPress::MOUSE_LEFT:
            // Проверяем, нажата ли кнопка мыши на пункте меню
            for (size_t i = 0; i < _activeMenuItems->size(); ++i) {
                MenuItem &item = (*_activeMenuItems)[i];
                
                if (mouseX >= item.x && mouseX <= item.x + item.width &&
                    mouseY >= item.y && mouseY <= item.y + item.height) {
                    item.action();
                    return;
                }
            }
            break;
            
        default:
            break;
    }
}

MenuState Menu::getCurrentState() const {
    return _currentState;
}

GameMode Menu::getSelectedGameMode() const {
    return _selectedGameMode;
}

void Menu::setGameOver() {
    switchToMenu(MenuState::GAME_OVER);
}

void Menu::setPause() {
    switchToMenu(MenuState::PAUSE);
} 