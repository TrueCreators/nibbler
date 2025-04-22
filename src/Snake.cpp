#include "../includes/Snake.hpp"
#include "../includes/IGraphicsLib.hpp"
#include <iostream>

Snake::Snake(int x, int y, int initialSize) {
    // Создаем начальное тело змейки
    for (int i = 0; i < initialSize; ++i) {
        _body.push_back({x - i, y});
    }
    _direction = Direction::RIGHT;
    _delayMove = false;
    _shouldGrow = false;
    _hasMoved = false;
    _forceLeftMove = false;
}

Snake::~Snake() {}

void Snake::move() {
    // Обработка принудительного движения влево
    if (_forceLeftMove) {
        _forceLeftMove = false;
        _delayMove = false;
        
        // Гарантированно двигаемся влево
        Position newHead = _body.front();
        newHead.x--;
        
        // Проверяем столкновение с телом (кроме головы)
        for (size_t i = 1; i < _body.size(); ++i) {
            if (newHead.x == _body[i].x && newHead.y == _body[i].y) {
                // Добавляем голову, чтобы отобразить столкновение
                _body.push_front(newHead);
                // Удаляем хвост, чтобы сохранить размер
                _body.pop_back();
                _hasMoved = true;
                return;
            }
        }
        
        // Добавляем новую голову в начало
        _body.push_front(newHead);
        
        // Обработка роста
        if (_shouldGrow) {
            _shouldGrow = false;
        } else {
            // Удаляем хвост
            _body.pop_back();
        }
        
        _hasMoved = true;
        return;
    }
    
    // Если установлен флаг задержки, пропускаем ход
    if (_delayMove) {
        _delayMove = false;
        return;
    }
    
    // Получаем текущую позицию головы
    Position newHead = _body.front();
    
    // Вычисляем новую позицию головы в зависимости от направления
    switch (_direction) {
        case Direction::UP:
            newHead.y--;
            break;
        case Direction::DOWN:
            newHead.y++;
            break;
        case Direction::LEFT:
            newHead.x--;
            break;
        case Direction::RIGHT:
            newHead.x++;
            break;
    }
    
    // Проверка на столкновение с телом (кроме головы и хвоста)
    // Проверяем с индекса 1 до size-1, чтобы игнорировать хвост, который будет удален
    for (size_t i = 1; i < _body.size() - (_shouldGrow ? 0 : 1); ++i) {
        if (newHead.x == _body[i].x && newHead.y == _body[i].y) {
            // Добавляем голову, чтобы отобразить столкновение
            _body.push_front(newHead);
            // Удаляем хвост, чтобы сохранить размер
            if (!_shouldGrow) {
                _body.pop_back();
            }
            _hasMoved = true;
            return;
        }
    }
    
    // Добавляем новую голову
    _body.push_front(newHead);
    
    // Обработка роста
    if (_shouldGrow) {
        _shouldGrow = false;
    } else {
        // Иначе удаляем хвост
        _body.pop_back();
    }
    
    _hasMoved = true;
}

void Snake::forceLeftMovement() {
    // Принудительно гарантирует движение влево в следующем кадре
    _forceLeftMove = true;
    _direction = Direction::LEFT;
    
    // Очищаем флаг задержки, если он был установлен
    _delayMove = false;
    
    std::cout << "Forcing LEFT movement in the next frame" << std::endl;
}

void Snake::setDirection(Direction newDirection) {
    // Если активировано принудительное движение влево, не меняем направление
    if (_forceLeftMove && newDirection != Direction::LEFT) {
        return;
    }
    
    // Проверяем, что новое направление не противоположно текущему
    // и не равно текущему (оптимизация)
    if (newDirection == _direction) {
        return; // Уже движемся в этом направлении
    }
    
    // Проверка на противоположное направление
    bool isOpposite = 
        (_direction == Direction::UP && newDirection == Direction::DOWN) ||
        (_direction == Direction::DOWN && newDirection == Direction::UP) ||
        (_direction == Direction::LEFT && newDirection == Direction::RIGHT) ||
        (_direction == Direction::RIGHT && newDirection == Direction::LEFT);
    
    if (isOpposite) {
        // Не позволяем мгновенно развернуться
        return;
    }
    
    // Если змейка только что сделала поворот и не сделала шаг, не меняем направление снова
    if (!_hasMoved && _direction != _nextDirection) {
        return;
    }
    
    // Устанавливаем новое направление
    _direction = newDirection;
    _nextDirection = newDirection;
    _hasMoved = false; // Сбрасываем флаг движения
}

void Snake::grow() {
    _shouldGrow = true;
}

void Snake::shrink() {
    // Уменьшаем длину змейки, удаляя последний сегмент тела
    if (_body.size() > 1) { // Всегда оставляем хотя бы голову
        _body.pop_back();
        std::cout << "Змейка уменьшилась. Новая длина: " << _body.size() << std::endl;
    }
}

bool Snake::checkSelfCollision() const {
    // Если активирован режим принудительного движения влево, не проверяем коллизии
    if (_forceLeftMove) {
        return false;
    }
    
    // Если нет тела или только голова, коллизии быть не может
    if (_body.size() <= 1) {
        return false;
    }
    
    const Position &head = getHead();
    
    // Проверяем каждый сегмент тела, кроме головы
    for (size_t i = 1; i < _body.size(); ++i) {
        if (head.x == _body[i].x && head.y == _body[i].y) {
            // Обнаружено столкновение
            std::cout << "Self collision detected at position (" << head.x << "," << head.y << ")" << std::endl;
            return true;
        }
    }
    
    return false;
}

bool Snake::checkWallCollision(int width, int height) const {
    // Если активирован режим принудительного движения влево,
    // проверяем только левую границу (x < 0)
    if (_forceLeftMove) {
        return getHead().x < 0;
    }
    
    const Position &head = getHead();
    
    // Стандартная проверка для всех направлений
    return head.x < 0 || head.x >= width || head.y < 0 || head.y >= height;
}

bool Snake::checkFoodCollision(const Position &food) const {
    const Position &head = getHead();
    return head.x == food.x && head.y == food.y;
}

Direction Snake::getDirection() const {
    return _direction;
}

Position Snake::getHead() const {
    return _body.front();
}

const std::deque<Position>& Snake::getBody() const {
    return _body;
}

void Snake::setBody(const std::deque<Position>& body) {
    // Копируем тело
    _body.clear();
    for (const auto& segment : body) {
        _body.push_back(segment);
    }
    
    // Принудительно отключаем проверку коллизий для следующего хода
    // и устанавливаем направление вправо, если не задано иное
    _delayMove = true;
    
    // Не переопределяем направление, если оно уже установлено
    _hasMoved = true; // Устанавливаем флаг движения, чтобы избежать сброса направления
}

void Snake::delayNextMove() {
    _delayMove = true;
}

void Snake::clearBody() {
    // Сохраняем только голову
    if (!_body.empty()) {
        Position head = _body.front();
        _body.clear();
        _body.push_back(head);
    }
}

void Snake::addSegment(const Position &pos) {
    // Добавляем новый сегмент в конец тела
    _body.push_back(pos);
} 