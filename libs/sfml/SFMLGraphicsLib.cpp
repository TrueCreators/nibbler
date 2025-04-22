#include "SFMLGraphicsLib.hpp"
#include <iostream>

SFMLGraphicsLib::SFMLGraphicsLib()
    : _window(nullptr), _width(0), _height(0), _cellSize(20), _frameDelay(100) {
    
    // Инициализация цветов
    _backgroundColor = sf::Color::Black;
    _snakeColor = sf::Color::Green;
    _foodColor = sf::Color::Red;
    _wallColor = sf::Color(128, 128, 128); // Серый
    _menuBackgroundColor = sf::Color(20, 20, 50); // Темно-синий
    _buttonColor = sf::Color(70, 70, 120); // Темно-фиолетовый
    _buttonHoverColor = sf::Color(100, 100, 180); // Светло-фиолетовый
    _buttonSelectedColor = sf::Color(120, 120, 220); // Ярко-фиолетовый
    _textColor = sf::Color::White;
    
    // Позиция мыши
    _mousePosition = sf::Vector2i(0, 0);
}

SFMLGraphicsLib::~SFMLGraphicsLib() {
    cleanup();
}

bool SFMLGraphicsLib::init(int width, int height, const std::string &title) {
    _width = width;
    _height = height;
    
    // Создание окна SFML
    _window = new sf::RenderWindow(
        sf::VideoMode(_width * _cellSize, _height * _cellSize),
        title,
        sf::Style::Titlebar | sf::Style::Close
    );
    
    // Ограничение частоты кадров
    _window->setFramerateLimit(60);
    
    // Загрузка шрифта
    std::cout << "Пытаюсь загрузить шрифт из /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf для SFML..." << std::endl;
    if (!_font.loadFromFile("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")) {
        std::cerr << "Ошибка загрузки шрифта из системного пути для SFML" << std::endl;
        
        // Пробуем загрузить из локальной директории
        std::cout << "Пытаюсь загрузить шрифт из текущей директории для SFML..." << std::endl;
        if (!_font.loadFromFile("DejaVuSans.ttf")) {
            std::cerr << "Ошибка загрузки шрифта из текущей директории для SFML" << std::endl;
        } else {
            std::cout << "Шрифт успешно загружен из текущей директории для SFML" << std::endl;
        }
    } else {
        std::cout << "Шрифт успешно загружен из системной директории для SFML" << std::endl;
    }
    
    // Создание фигур для рисования
    createShapes();
    
    return true;
}

void SFMLGraphicsLib::createShapes() {
    // Создаем фигуру для головы змейки
    _snakeHeadShape.setSize(sf::Vector2f(_cellSize, _cellSize));
    _snakeHeadShape.setFillColor(_snakeColor);
    
    // Создаем фигуру для тела змейки
    _snakeBodyShape.setSize(sf::Vector2f(_cellSize - 2, _cellSize - 2));
    _snakeBodyShape.setFillColor(_snakeColor);
    
    // Создаем фигуру для еды
    _foodShape.setRadius((_cellSize - 4) / 2.0f);
    _foodShape.setFillColor(_foodColor);
    
    // Создаем фигуру для стены
    _wallShape.setSize(sf::Vector2f(_cellSize, _cellSize));
    _wallShape.setFillColor(_wallColor);
}

void SFMLGraphicsLib::cleanup() {
    if (_window) {
        _window->close();
        delete _window;
        _window = nullptr;
    }
}

void SFMLGraphicsLib::drawSnake(int x, int y, Direction dir) {
    if (!_window) {
        return;
    }
    
    // Устанавливаем позицию головы змейки
    _snakeHeadShape.setPosition(x * _cellSize, y * _cellSize);
    
    // Отрисовываем голову
    _window->draw(_snakeHeadShape);
    
    // Рисуем глаза в зависимости от направления
    float eyeSize = _cellSize / 6.0f;
    sf::CircleShape eye(eyeSize);
    eye.setFillColor(sf::Color::White);
    
    // Расположение глаз зависит от направления
    switch (dir) {
        case Direction::UP:
            eye.setPosition(x * _cellSize + _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4);
            _window->draw(eye);
            eye.setPosition(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4);
            _window->draw(eye);
            break;
        case Direction::DOWN:
            eye.setPosition(x * _cellSize + _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize);
            _window->draw(eye);
            eye.setPosition(x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize);
            _window->draw(eye);
            break;
        case Direction::LEFT:
            eye.setPosition(x * _cellSize + _cellSize / 4, y * _cellSize + _cellSize / 4 - eyeSize);
            _window->draw(eye);
            eye.setPosition(x * _cellSize + _cellSize / 4, y * _cellSize + 3 * _cellSize / 4 - eyeSize);
            _window->draw(eye);
            break;
        case Direction::RIGHT:
            eye.setPosition(x * _cellSize + 3 * _cellSize / 4 - eyeSize * 2, y * _cellSize + _cellSize / 4 - eyeSize);
            _window->draw(eye);
            eye.setPosition(x * _cellSize + 3 * _cellSize / 4 - eyeSize * 2, y * _cellSize + 3 * _cellSize / 4 - eyeSize);
            _window->draw(eye);
            break;
    }
}

void SFMLGraphicsLib::drawSnakeSection(int x, int y) {
    if (!_window) {
        return;
    }
    
    // Устанавливаем позицию секции тела змейки
    _snakeBodyShape.setPosition(x * _cellSize + 1, y * _cellSize + 1);
    
    // Отрисовываем тело
    _window->draw(_snakeBodyShape);
}

void SFMLGraphicsLib::drawFood(int x, int y) {
    if (!_window) {
        return;
    }
    
    // Устанавливаем позицию еды
    _foodShape.setPosition(x * _cellSize + 2, y * _cellSize + 2);
    
    // Отрисовываем еду
    _window->draw(_foodShape);
}

void SFMLGraphicsLib::drawWall(int x, int y) {
    if (!_window) {
        return;
    }
    
    // Устанавливаем позицию стены
    _wallShape.setPosition(x * _cellSize, y * _cellSize);
    
    // Отрисовываем стену
    _window->draw(_wallShape);
}

void SFMLGraphicsLib::clearScreen() {
    if (!_window) {
        return;
    }
    
    _window->clear(_backgroundColor);
}

void SFMLGraphicsLib::updateScreen() {
    if (!_window) {
        return;
    }
    
    _window->display();
    sf::sleep(sf::milliseconds(_frameDelay));
}

KeyPress SFMLGraphicsLib::getInput() {
    if (!_window) {
        return KeyPress::NONE;
    }
    
    // Обновляем позицию мыши
    _mousePosition = sf::Mouse::getPosition(*_window);
    
    sf::Event event;
    while (_window->pollEvent(event)) {
        if (event.type == sf::Event::Closed) {
            return KeyPress::ESC;
        }
        
        if (event.type == sf::Event::KeyPressed) {
            switch (event.key.code) {
                case sf::Keyboard::Up:
                    return KeyPress::UP;
                case sf::Keyboard::Down:
                    return KeyPress::DOWN;
                case sf::Keyboard::Left:
                    return KeyPress::LEFT;
                case sf::Keyboard::Right:
                    return KeyPress::RIGHT;
                case sf::Keyboard::Num1:
                case sf::Keyboard::Numpad1:
                    return KeyPress::ONE;
                case sf::Keyboard::Num2:
                case sf::Keyboard::Numpad2:
                    return KeyPress::TWO;
                case sf::Keyboard::Num3:
                case sf::Keyboard::Numpad3:
                    return KeyPress::THREE;
                case sf::Keyboard::R:
                    return KeyPress::RESTART;
                case sf::Keyboard::Return:
                    return KeyPress::ENTER;
                case sf::Keyboard::Escape:
                    return KeyPress::ESC;
                default:
                    break;
            }
        }
        
        if (event.type == sf::Event::MouseButtonPressed) {
            if (event.mouseButton.button == sf::Mouse::Left) {
                return KeyPress::MOUSE_LEFT;
            }
        }
    }
    
    return KeyPress::NONE;
}

bool SFMLGraphicsLib::isWindowOpen() {
    return (_window != nullptr && _window->isOpen());
}

void SFMLGraphicsLib::setFrameDelay(int ms) {
    _frameDelay = ms;
}

void SFMLGraphicsLib::drawText(const std::string &text, int x, int y, int fontSize, bool isCentered) {
    if (!_window) {
        return;
    }
    
    sf::Text textObj;
    textObj.setFont(_font);
    textObj.setString(text);
    textObj.setCharacterSize(fontSize);
    textObj.setFillColor(_textColor);
    
    // Если шрифт не загружен, рисуем прямоугольник
    if (!_font.getInfo().family.empty()) {
        // Получаем размеры текста
        sf::FloatRect textRect = textObj.getLocalBounds();
        
        // Устанавливаем позицию текста
        if (isCentered) {
            textObj.setPosition(x - textRect.width / 2.0f, y);
        } else {
            textObj.setPosition(x, y);
        }
        
        // Отрисовываем текст
        _window->draw(textObj);
    } else {
        // Рисуем прямоугольник, если шрифт не загружен
        sf::RectangleShape rect;
        rect.setSize(sf::Vector2f(text.length() * fontSize * 0.6f, fontSize));
        rect.setOutlineColor(_textColor);
        rect.setOutlineThickness(1);
        rect.setFillColor(sf::Color::Transparent);
        
        if (isCentered) {
            rect.setPosition(x - (text.length() * fontSize * 0.6f) / 2.0f, y);
        } else {
            rect.setPosition(x, y);
        }
        
        _window->draw(rect);
    }
}

bool SFMLGraphicsLib::drawButton(const std::string &text, int x, int y, int width, int height, bool isSelected, int fontSize) {
    if (!_window) return false;
    
    // Получаем позицию мыши
    sf::Vector2i mousePos = sf::Mouse::getPosition(*_window);
    bool isHovered = mousePos.x >= x && mousePos.x <= x + width &&
                    mousePos.y >= y && mousePos.y <= y + height;
    
    // Создаем прямоугольник кнопки
    sf::RectangleShape button(sf::Vector2f(width, height));
    button.setPosition(x, y);
    
    // Устанавливаем цвет в зависимости от состояния
    if (isSelected || isHovered) {
        button.setFillColor(sf::Color(100, 100, 100)); // Серый для выделенной кнопки
    } else {
        button.setFillColor(sf::Color(50, 50, 50));    // Темно-серый для обычной кнопки
    }
    
    // Устанавливаем рамку
    button.setOutlineThickness(1);
    button.setOutlineColor(sf::Color::White);
    
    // Рисуем кнопку
    _window->draw(button);
    
    // Рисуем текст
    sf::Text buttonText;
    buttonText.setFont(_font);
    buttonText.setString(text);
    buttonText.setCharacterSize(fontSize);
    buttonText.setFillColor(sf::Color::White);
    
    // Центрируем текст
    sf::FloatRect textBounds = buttonText.getLocalBounds();
    buttonText.setPosition(
        x + (width - textBounds.width) / 2,
        y + (height - textBounds.height) / 2
    );
    
    _window->draw(buttonText);
    
    return isHovered;
}

void SFMLGraphicsLib::getMousePosition(int &x, int &y) {
    x = _mousePosition.x;
    y = _mousePosition.y;
}

void SFMLGraphicsLib::drawMenuBackground() {
    if (!_window) return;
    
    // Create semi-transparent overlay
    sf::RectangleShape overlay;
    overlay.setSize(sf::Vector2f(getWindowWidth(), getWindowHeight()));
    overlay.setFillColor(sf::Color(0, 0, 0, 128)); // Black with 50% opacity
    _window->draw(overlay);
}

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create() {
        return new SFMLGraphicsLib();
    }
    
    void destroy(IGraphicsLib* instance) {
        delete instance;
    }
}