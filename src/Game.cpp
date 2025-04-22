#include "../includes/Game.hpp"
#include <iostream>
#include <chrono>
#include <thread>

Game::Game(int width, int height, const std::vector<std::string> &libPaths)
    : _width(width), _height(height), _speed(100), _state(GameState::MENU),
      _gameMode(GameMode::CLASSIC), _snake(nullptr), _food(nullptr), 
      _libPaths(libPaths), _currentLibIndex(0), _savedState(nullptr) {
    
    if (_libPaths.empty()) {
        throw std::runtime_error("Не указаны пути к графическим библиотекам");
    }

    // Сортируем библиотеки в правильном порядке: SDL, SFML, Raylib
    std::vector<std::string> sortedPaths;
    // Ищем SDL
    for (const auto &path : _libPaths) {
        if (path.find("sdl") != std::string::npos) {
            sortedPaths.push_back(path);
            break;
        }
    }
    // Ищем SFML
    for (const auto &path : _libPaths) {
        if (path.find("sfml") != std::string::npos) {
            sortedPaths.push_back(path);
            break;
        }
    }
    // Ищем Raylib
    for (const auto &path : _libPaths) {
        if (path.find("raylib") != std::string::npos) {
            sortedPaths.push_back(path);
            break;
        }
    }
    
    // Проверяем, что нашли хотя бы одну библиотеку
    if (sortedPaths.empty()) {
        // Если не нашли ни одной из известных, используем все переданные
        _libPaths = libPaths;
    } else {
        _libPaths = sortedPaths;
    }
    
    std::cout << "Доступные библиотеки:" << std::endl;
    for (const auto &path : _libPaths) {
        std::cout << " - " << path << std::endl;
    }
    
    // Инициализируем систему меню
    _menu.init();
    
    try {
        // Проверяем наличие хотя бы одной библиотеки
        if (_libPaths.empty()) {
            throw std::runtime_error("Не найдено ни одной графической библиотеки");
        }
        
        // Пытаемся загрузить первую доступную библиотеку
        bool libraryLoaded = false;
        std::string lastError;
        
        for (size_t i = 0; i < _libPaths.size(); ++i) {
            try {
                std::cout << "Попытка загрузки библиотеки: " << _libPaths[i] << std::endl;
                
                _libLoader.loadLibrary(_libPaths[i]);
                if (_libLoader.isLoaded()) {
                    _libLoader.getInstance()->init(_width, _height, "Nibbler");
                    _libLoader.getInstance()->setFrameDelay(_speed);
                    _currentLibIndex = i;
                    libraryLoaded = true;
                    
                    std::cout << "Успешно загружена библиотека: " << _libPaths[i] << std::endl;
                    
                    break;
                }
            } catch (const std::exception &e) {
                lastError = e.what();
                std::cout << "Ошибка при загрузке библиотеки " << _libPaths[i] << ": " << lastError << std::endl;
                
                if (_libLoader.isLoaded()) {
                    _libLoader.getInstance()->cleanup();
                    _libLoader.unloadLibrary();
                }
                continue;
            }
        }
        
        if (!libraryLoaded) {
            throw std::runtime_error("Не удалось загрузить ни одну графическую библиотеку. Последняя ошибка: " + lastError);
        }
        
    } catch (const std::exception &e) {
        // Очищаем ресурсы в случае ошибки
        if (_libLoader.isLoaded()) {
            _libLoader.getInstance()->cleanup();
            _libLoader.unloadLibrary();
        }
        throw;
    }
}

Game::~Game() {
    delete _snake;
    delete _food;
    delete _savedState;  // Добавляем очистку сохраненного состояния
}

void Game::init() {
    // Вычисляем безопасную начальную позицию для змейки
    int initialSize = 4; // Начальный размер змейки
    int startX = _width / 3;  // Размещаем в первой трети поля по горизонтали
    int startY = _height / 2; // По центру по вертикали
    
    if (startX - (initialSize - 1) < 1) {
        startX = initialSize;
    }
    
    if (startX + 2 >= _width) {
        startX = _width / 2;
    }
    
    // Безопасное удаление старых объектов
    if (_snake) {
        delete _snake;
        _snake = nullptr;
    }
    if (_food) {
        delete _food;
        _food = nullptr;
    }
    
    try {
        _snake = new Snake(startX, startY, initialSize);
        if (!_snake) {
            throw std::runtime_error("Не удалось создать змейку");
        }
        
        // Проверка на коллизию со стеной
        if (_snake->checkWallCollision(_width, _height)) {
            delete _snake;
            _snake = nullptr;
            
            startX = _width / 2 - 2;
            if (startX < 2) startX = 2;
            
            startY = _height / 2;
            if (startY < 2) startY = 2;
            
            _snake = new Snake(startX, startY, initialSize);
            if (!_snake) {
                throw std::runtime_error("Не удалось создать змейку после перепозиционирования");
            }
            
            if (_snake->checkWallCollision(_width, _height)) {
                throw std::runtime_error("Невозможно создать змейку в пределах игрового поля");
            }
        }
        
        // Создаем еду
        _food = new Food(_width, _height);
        if (!_food) {
            throw std::runtime_error("Не удалось создать еду");
        }
        
        // Проверка, не совпадает ли еда с телом змейки
        const Position &foodPos = _food->getPosition();
        bool foodCollision = false;
        for (const auto& segment : _snake->getBody()) {
            if (segment.x == foodPos.x && segment.y == foodPos.y) {
                foodCollision = true;
                break;
            }
        }
        
        if (foodCollision) {
            _food->respawn(_width, _height, *_snake);
        }
        
        // Устанавливаем скорость в зависимости от режима игры
        updateGameMode();
        
        // Устанавливаем задержку кадров для библиотеки
        if (_libLoader.isLoaded()) {
            _libLoader.getInstance()->setFrameDelay(_speed);
        }
        
    } catch (const std::exception &e) {
        // Очищаем ресурсы в случае ошибки
        if (_snake) {
            delete _snake;
            _snake = nullptr;
        }
        if (_food) {
            delete _food;
            _food = nullptr;
        }
        throw;
    }
}

void Game::handleInput() {
    if (!_libLoader.isLoaded()) {
        return;
    }
    
    KeyPress key = _libLoader.getInstance()->getInput();
    
    // Обработка клавиш переключения библиотек (доступны в любом состоянии)
    if (key == KeyPress::ONE || key == KeyPress::TWO || key == KeyPress::THREE) {
        size_t index = 0;
        if (key == KeyPress::ONE) index = 0;
        else if (key == KeyPress::TWO) index = 1;
        else if (key == KeyPress::THREE) index = 2;
        
        switchLibrary(index);
        return;
    }
    
    // В состоянии MENU, PAUSED или GAME_OVER обрабатываем навигационные клавиши UP/DOWN напрямую
    if ((_state == GameState::MENU || _state == GameState::PAUSED || _state == GameState::GAME_OVER) && 
        (key == KeyPress::UP || key == KeyPress::DOWN)) {
        _menu.processInput(key, _libLoader.getInstance());
        return;
    }
    
    // Для остальных клавиш используем специфическую для каждого состояния обработку
    handleStateSpecificInput(key);
}

void Game::update() {
    if (_state != GameState::RUNNING || !_snake || !_food) {
        return;
    }
    
    // Проверяем столкновение с собой до движения
    if (_snake->checkSelfCollision()) {
        // Сохраняем счет игрока перед переходом в Game Over
        int score = static_cast<int>(_snake->getBody().size() - 4);
        std::cout << "Game Over! Self collision detected. Final score: " << score << std::endl;
        _menu.setGameOver();
        _state = GameState::GAME_OVER;
        return;
    }
    
    // Move snake
    _snake->move();
    
    // Check wall collision
    if (_snake->checkWallCollision(_width, _height)) {
        // Сохраняем счет игрока перед переходом в Game Over
        int score = static_cast<int>(_snake->getBody().size() - 4);
        std::cout << "Game Over! Wall collision detected. Final score: " << score << std::endl;
        _menu.setGameOver();
        _state = GameState::GAME_OVER;
        return;
    }
    
    // Проверяем столкновение после движения еще раз
    // Это нужно потому что новая голова может создать столкновение
    if (_snake->checkSelfCollision()) {
        // Сохраняем счет игрока перед переходом в Game Over
        int score = static_cast<int>(_snake->getBody().size() - 4);
        std::cout << "Game Over! Self collision after move. Final score: " << score << std::endl;
        _menu.setGameOver();
        _state = GameState::GAME_OVER;
        return;
    }
    
    // Check if snake ate food
    if (_snake->checkFoodCollision(_food->getPosition())) {
        _snake->grow();
        
        // In Dynamic Speed mode, increase speed with each food eaten
        if (_gameMode == GameMode::DYNAMIC_SPEED) {
            _speed = std::max(30, _speed - 5);
            _libLoader.getInstance()->setFrameDelay(_speed);
        }
        
        // Snack Sprint mode - food runs away from snake
        if (_gameMode == GameMode::SNACK_SPRINT) {
            _food->respawnFarFromSnake(_width, _height, *_snake);
        } else {
            _food->respawn(_width, _height, *_snake);
        }
    }
}

void Game::updateGameMode() {
    _gameMode = _menu.getSelectedGameMode();
    
    switch (_gameMode) {
        case GameMode::CLASSIC:
            _speed = 50;  // Было 100, уменьшаем для более быстрого отклика
            break;
        case GameMode::DYNAMIC_SPEED:
            _speed = 60;  // Было 120, уменьшаем для более быстрого отклика
            break;
        case GameMode::SNACK_SPRINT:
            _speed = 40;  // Было 80, уменьшаем для более быстрого отклика
            break;
        case GameMode::SURVIVAL:
            _speed = 45;  // Было 90, уменьшаем для более быстрого отклика
            break;
        case GameMode::CONTINUE:
            // Не меняем скорость при продолжении игры
            break;
    }
    
    _libLoader.getInstance()->setFrameDelay(_speed);
}

void Game::render() {
    if (!_libLoader.isLoaded()) {
        return;
    }
    
    IGraphicsLib *lib = _libLoader.getInstance();
    
    // Рисуем границы поля
    // Верхняя и нижняя границы (включая углы)
    for (int x = 0; x < _width; ++x) {
        lib->drawWall(x, 0);
        lib->drawWall(x, _height - 1);
    }
    
    // Левая и правая границы (без углов, они уже нарисованы)
    for (int y = 1; y < _height - 1; ++y) {
        lib->drawWall(0, y);
        lib->drawWall(_width - 1, y);
    }
    
    // Определяем текущую библиотеку
    std::string libText;
    std::string currentLib = _libPaths[_currentLibIndex];
    if (currentLib.find("sdl") != std::string::npos) {
        libText = "SDL (1)";
    } else if (currentLib.find("sfml") != std::string::npos) {
        libText = "SFML (2)";
    } else if (currentLib.find("raylib") != std::string::npos) {
        libText = "Raylib (3)";
    }
    
    // Рисуем информацию о библиотеке
    lib->drawText(libText, _width * 10, 10, 16);
    
    // Отображаем игровые объекты если они существуют
    if (_snake && _food) {
        // Рисуем еду
        const Position &foodPos = _food->getPosition();
        lib->drawFood(foodPos.x, foodPos.y);
        
        // Рисуем змейку
        const std::deque<Position> &body = _snake->getBody();
        
        // Сначала рисуем голову
        if (!body.empty()) {
            lib->drawSnake(body.front().x, body.front().y, _snake->getDirection());
        }
        
        // Затем рисуем остальное тело
        for (size_t i = 1; i < body.size(); ++i) {
            lib->drawSnakeSection(body[i].x, body[i].y);
        }
        
        // Отображаем информацию о текущем режиме игры
        std::string modeText;
        switch (_gameMode) {
            case GameMode::CLASSIC:
                modeText = "Classic Mode";
                break;
            case GameMode::DYNAMIC_SPEED:
                modeText = "Dynamic Speed";
                break;
            case GameMode::SNACK_SPRINT:
                modeText = "Snack Sprint";
                break;
            case GameMode::SURVIVAL:
                modeText = "Survival Mode";
                break;
            case GameMode::CONTINUE:
                modeText = "Continue Game";
                break;
        }
        
        // Отображаем счёт (размер змейки - начальный размер)
        std::string scoreText = "Score: " + std::to_string(_snake->getBody().size() - 4);
        
        // Рисуем информацию в верхней части экрана
        lib->drawText(modeText, 10, 10, 16);
        lib->drawText(scoreText, _width * 20 - 100, 10, 16);
    }
}

void Game::renderMenu() {
    if (!_libLoader.isLoaded()) {
        return;
    }
    
    // Отрисовка меню с помощью текущей графической библиотеки
    _menu.render(_libLoader.getInstance());
}

void Game::handleMenuInput(KeyPress key) {
    if (!_libLoader.isLoaded()) {
        return;
    }
    
    // Обработка клавиш, которые работают во всех меню
    switch (key) {
        case KeyPress::ONE:
            switchLibrary(0);
            return;
        case KeyPress::TWO:
            switchLibrary(1);
            return;
        case KeyPress::THREE:
            switchLibrary(2);
            return;
        case KeyPress::ESC:
            // Если мы в режиме паузы, возобновляем игру
            if (_state == GameState::PAUSED) {
                restoreGameState();
                if (_snake && _food) {
                    _state = GameState::RUNNING;
                }
                return;
            }
            break;
        default:
            break;
    }
    
    // Передаем ввод в обработчик меню
    _menu.processInput(key, _libLoader.getInstance());
    
    // Получаем текущее состояние меню после обработки ввода
    MenuState menuState = _menu.getCurrentState();
    
    // Получаем выбранный режим игры
    GameMode selectedMode = _menu.getSelectedGameMode();
    
    // Обрабатываем новое состояние меню
    if (menuState == MenuState::GAME_RUNNING) {
        // Если игра была на паузе и выбран режим CONTINUE, восстанавливаем игру
        if (_state == GameState::PAUSED && selectedMode == GameMode::CONTINUE) {
            restoreGameState();
            if (_snake && _food) {
                _state = GameState::RUNNING;
            }
        } else {
            // В остальных случаях начинаем новую игру
            _gameMode = selectedMode;
            init();
            if (_snake && _food) {
                _state = GameState::RUNNING;
            }
        }
    } else if (menuState == MenuState::EXIT) {
        _state = GameState::EXIT;
    }
}

bool Game::switchLibrary(size_t index) {
    if (index >= _libPaths.size()) {
        return false;
    }
    
    // Проверяем, не пытаемся ли переключиться на ту же библиотеку
    if (index == _currentLibIndex && _libLoader.isLoaded()) {
        return true; // Уже используем эту библиотеку
    }
    
    // Сохраняем текущий индекс на случай ошибки
    size_t oldIndex = _currentLibIndex;
    
    try {
        // Полностью выгружаем текущую библиотеку
        if (_libLoader.isLoaded()) {
            _libLoader.getInstance()->cleanup();
            _libLoader.unloadLibrary();
        }
        
        // Добавляем небольшую задержку перед загрузкой новой библиотеки
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
        
        // Загружаем новую библиотеку
        _libLoader.loadLibrary(_libPaths[index]);
        
        if (!_libLoader.isLoaded()) {
            throw std::runtime_error("Не удалось загрузить новую библиотеку");
        }
        
        // Инициализируем новую библиотеку
        _libLoader.getInstance()->init(_width, _height, "Nibbler");
        _libLoader.getInstance()->setFrameDelay(_speed);
        _currentLibIndex = index;
        
        std::cout << "Успешно переключились на библиотеку: " << _libPaths[index] << std::endl;
        
        return true;
        
    } catch (const std::exception &e) {
        std::cerr << "Ошибка при переключении библиотеки: " << e.what() << std::endl;
        
        // Пытаемся восстановить предыдущую библиотеку
        try {
            if (oldIndex != index) {
                _libLoader.loadLibrary(_libPaths[oldIndex]);
                if (_libLoader.isLoaded()) {
                    _libLoader.getInstance()->init(_width, _height, "Nibbler");
                    _libLoader.getInstance()->setFrameDelay(_speed);
                    _currentLibIndex = oldIndex;
                    
                    std::cout << "Восстановлена предыдущая библиотека: " << _libPaths[oldIndex] << std::endl;
                    
                    return true;
                }
            }
            
            // Если не удалось восстановить предыдущую, пробуем любую доступную
            for (size_t i = 0; i < _libPaths.size(); ++i) {
                if (i != index && i != oldIndex) {
                    try {
                        std::cout << "Пытаемся загрузить альтернативную библиотеку: " << _libPaths[i] << std::endl;
                        
                        _libLoader.loadLibrary(_libPaths[i]);
                        if (_libLoader.isLoaded()) {
                            _libLoader.getInstance()->init(_width, _height, "Nibbler");
                            _libLoader.getInstance()->setFrameDelay(_speed);
                            _currentLibIndex = i;
                            return true;
                        }
                    } catch (...) {
                        continue;
                    }
                }
            }
        } catch (const std::exception &e) {
            // Если все попытки восстановления не удались
            std::cerr << "Критическая ошибка при восстановлении: " << e.what() << std::endl;
        } catch (...) {
            // Если все попытки восстановления не удались
            std::cerr << "Критическая ошибка: не удалось восстановить работу графической библиотеки" << std::endl;
        }
    }
    
    return false;
}

void Game::handleStateSpecificInput(KeyPress key) {
    switch (_state) {
        case GameState::RUNNING:
            switch (key) {
                case KeyPress::UP:
                    _snake->setDirection(Direction::UP);
                    break;
                case KeyPress::DOWN:
                    _snake->setDirection(Direction::DOWN);
                    break;
                case KeyPress::LEFT:
                    _snake->setDirection(Direction::LEFT);
                    break;
                case KeyPress::RIGHT:
                    _snake->setDirection(Direction::RIGHT);
                    break;
                case KeyPress::RESTART:
                    _state = GameState::RUNNING;
                    restart();
                    break;
                case KeyPress::ESC:
                    saveGameState();
                    _state = GameState::PAUSED;
                    _menu.setPause();
                    break;
                default:
                    break;
            }
            break;
            
        case GameState::MENU:
            handleMenuInput(key);
            break;
            
        case GameState::PAUSED:
            handleMenuInput(key);
            break;
            
        case GameState::GAME_OVER: {
            // Все клавиши просто передаем в обработчик меню
            _menu.processInput(key, _libLoader.getInstance());
            
            // После обработки проверяем текущее состояние меню
            MenuState menuState = _menu.getCurrentState();
            
            // Обработка разных состояний меню
            if (menuState == MenuState::MAIN_MENU) {
                // Если выбрано "Main Menu", переходим в главное меню
                _state = GameState::MENU;
                _menu.init(); // Переинициализируем меню в главное
                return; // Важно завершить обработку здесь, чтобы избежать конфликтов
            }
            else if (menuState == MenuState::GAME_RUNNING) {
                // Если выбрано "New Game", запускаем новую игру
                _state = GameState::RUNNING;
                restart();
                return;
            }
            else if (menuState == MenuState::EXIT) {
                // Если выбрано "Exit", выходим из игры
                _state = GameState::EXIT;
                return;
            }
            
            // Специальная обработка для клавиш ESC и ENTER/RESTART для Game Over
            if (key == KeyPress::ESC) {
                _state = GameState::MENU;
                _menu.init();
            } else if (key == KeyPress::RESTART || key == KeyPress::ENTER) {
                _state = GameState::RUNNING;
                restart();
            }
            break;
        }
            
        case GameState::EXIT:
            // Ничего не делаем, игра завершится в следующем цикле
            break;
            
        default:
            break;
    }
}

void Game::run() {
    bool running = true;
    auto prevFrameTime = std::chrono::high_resolution_clock::now();
    int frameDelay = _speed; // Используем текущую скорость игры для задержки кадров
    
    while (running && _libLoader.isLoaded()) {
        auto currentTime = std::chrono::high_resolution_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - prevFrameTime).count();
        
        if (elapsed >= frameDelay) {
            // Обработка ввода
            handleInput();
            
            // Обновление состояния игры
            if (_state == GameState::RUNNING) {
                update();
            }
            
            // Очистка экрана перед отрисовкой
            _libLoader.getInstance()->clearScreen();
            
            // В зависимости от состояния отрисовываем либо меню, либо игру
            if (_state == GameState::MENU || _state == GameState::PAUSED || _state == GameState::GAME_OVER) {
                renderMenu();
            } else {
                render();
            }
            
            // Обновление экрана
            _libLoader.getInstance()->updateScreen();
            
            // Сбрасываем таймер
            prevFrameTime = currentTime;
            
            // Проверяем состояние окна
            if (!_libLoader.getInstance()->isWindowOpen() || _state == GameState::EXIT) {
                running = false;
            }
        }
    }
}

void Game::restart() {
    // Пересоздаем игровые объекты
    init();
    _state = GameState::RUNNING;
}

GameState Game::getState() const {
    return _state;
}

bool Game::saveGameState() {
    if (!_snake || !_food) return false;
    
    try {
        // Очищаем предыдущее сохраненное состояние
        delete _savedState;
        _savedState = nullptr;
        
        // Получаем текущее тело змейки и направление
        auto snakeBody = _snake->getBody();
        auto direction = _snake->getDirection();
        
        std::cout << "Saving game state. Snake direction: " 
                  << (direction == Direction::UP ? "UP" : 
                     direction == Direction::DOWN ? "DOWN" : 
                     direction == Direction::LEFT ? "LEFT" : "RIGHT") 
                  << ", Body size: " << snakeBody.size() << std::endl;
        
        // Создаем новый снимок состояния
        _savedState = new GameSnapshot{
            snakeBody,
            direction,
            _food->getPosition(),
            static_cast<int>(snakeBody.size() - 4),
            _speed,
            _gameMode
        };
        
        // Проверяем, что данные сохранились правильно
        if (_savedState->snakeBody.size() != snakeBody.size()) {
            throw std::runtime_error("Snake body size mismatch in saved state");
        }
        
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Error saving game state: " << e.what() << std::endl;
        delete _savedState;
        _savedState = nullptr;
        return false;
    }
}

void Game::restoreGameState() {
    if (!_savedState) {
        std::cerr << "No saved state to restore" << std::endl;
        return;
    }
    
    try {
        // Delete old objects
        delete _snake;
        _snake = nullptr;
        delete _food;
        _food = nullptr;
        
        if (_savedState->snakeBody.empty()) {
            throw std::runtime_error("Saved snake body is empty");
        }
        
        // Create snake with initial position
        const Position& head = _savedState->snakeBody.front();
        _snake = new Snake(head.x, head.y, 4);
        
        if (!_snake) {
            throw std::runtime_error("Failed to create snake");
        }
        
        // Сначала восстановим тело
        _snake->setBody(_savedState->snakeBody);
        
        // Затем установим правильное направление 
        Direction direction = _savedState->snakeDirection;
        _snake->setDirection(direction);
        
        // Если змейка движется влево, принудительно обеспечим движение в следующем кадре
        if (direction == Direction::LEFT) {
            _snake->forceLeftMovement();
        }
        
        // Create food
        _food = new Food(_width, _height);
        if (!_food) {
            throw std::runtime_error("Failed to create food");
        }
        
        // Set food position
        _food->setPosition(_savedState->foodPosition);
        
        // Restore game parameters
        _speed = _savedState->speed;
        _gameMode = _savedState->gameMode;
        
        // Update graphics library
        if (_libLoader.isLoaded()) {
            _libLoader.getInstance()->setFrameDelay(_speed);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "Error restoring state: " << e.what() << std::endl;
        // Clean up in case of error
        delete _snake;
        delete _food;
        _snake = nullptr;
        _food = nullptr;
        // Initialize new game as fallback
        init();
    }
} 