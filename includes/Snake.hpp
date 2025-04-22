#ifndef SNAKE_HPP
#define SNAKE_HPP

#include <vector>
#include <deque>
#include "IGraphicsLib.hpp"
#include "Position.hpp"

enum class Direction;

class Snake {
private:
    std::deque<Position> _body;
    Direction _direction;
    Direction _nextDirection;
    bool _growing;
    bool _hasGrown;
    bool _hasMoved;
    bool _shouldGrow;
    bool _delayMove;
    bool _forceLeftMove;

public:
    Snake(int x, int y, int initialSize = 4);
    ~Snake();

    // Перемещение змейки
    void move();
    
    // Установка следующего направления движения
    void setDirection(Direction dir);
    
    // Увеличение длины змейки
    void grow();
    
    // Уменьшение длины змейки (для режима выживания)
    void shrink();
    
    // Проверка столкновения с самим собой
    bool checkSelfCollision() const;
    
    // Проверка столкновения со стеной
    bool checkWallCollision(int width, int height) const;
    
    // Проверка съедания еды
    bool checkFoodCollision(const Position &food) const;
    
    // Получение текущего направления
    Direction getDirection() const;
    
    // Получение координат головы
    Position getHead() const;
    
    // Получение всего тела змейки
    const std::deque<Position>& getBody() const;
    
    void setBody(const std::deque<Position>& body);
    void delayNextMove();
    void forceLeftMovement();

    // Новые методы для более точного контроля над телом змейки
    void clearBody();      // Очистить тело (оставить только голову)
    void addSegment(const Position &pos);  // Добавить сегмент в конец тела
};

#endif // SNAKE_HPP 