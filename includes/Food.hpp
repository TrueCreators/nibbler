#ifndef FOOD_HPP
#define FOOD_HPP

#include "Position.hpp"
#include "Snake.hpp"
#include <random>

class Food {
private:
    Position _position;
    int _width;
    int _height;
    std::mt19937 _rng;  // Генератор случайных чисел

public:
    // Конструктор создает еду в случайной позиции
    Food(int width, int height);
    ~Food() = default;

    // Получение текущей позиции еды
    const Position& getPosition() const;

    // Перемещение еды в новую случайную позицию
    void respawn(int width, int height, const Snake& snake);

    // Размещение еды максимально далеко от змеи (для режима Sprint)
    void respawnFarFromSnake(int width, int height, const Snake& snake);

    void setPosition(const Position& pos);  // Новый метод
};

#endif // FOOD_HPP 