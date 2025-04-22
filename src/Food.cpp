#include "../includes/Food.hpp"
#include <algorithm>
#include <ctime>
#include <cmath>
#include <vector>

Food::Food(int width, int height) : _rng(std::random_device()()) {
    // Размещаем еду в случайной позиции
    std::uniform_int_distribution<int> distX(1, width - 2);  // Избегаем стены
    std::uniform_int_distribution<int> distY(1, height - 2); // Избегаем стены
    
    _position.x = distX(_rng);
    _position.y = distY(_rng);
}

const Position& Food::getPosition() const {
    return _position;
}

void Food::respawn(int width, int height, const Snake &snake) {
    std::uniform_int_distribution<int> distX(1, width - 2);  // Избегаем стены
    std::uniform_int_distribution<int> distY(1, height - 2); // Избегаем стены
    
    const std::deque<Position>& snakeBody = snake.getBody();
    
    // Генерируем новую позицию, пока она не будет отличаться от всех частей змейки
    do {
        _position.x = distX(_rng);
        _position.y = distY(_rng);
    } while (std::find_if(snakeBody.begin(), snakeBody.end(), 
                         [this](const Position &pos) { 
                             return pos.x == _position.x && pos.y == _position.y; 
                         }) != snakeBody.end());
}

void Food::respawnFarFromSnake(int width, int height, const Snake &snake) {
    const std::deque<Position>& snakeBody = snake.getBody();
    Position headPos = snake.getHead();
    
    // Создаем вектор возможных позиций (все позиции на поле, кроме позиций змейки и стен)
    std::vector<Position> possiblePositions;
    
    // Заполняем вектор всеми позициями на игровом поле
    for (int x = 1; x < width - 1; ++x) {
        for (int y = 1; y < height - 1; ++y) {
            Position pos(x, y);
            
            // Проверяем, что позиция не совпадает с телом змейки
            if (std::find_if(snakeBody.begin(), snakeBody.end(),
                           [&pos](const Position &snakePos) {
                               return pos.x == snakePos.x && pos.y == snakePos.y;
                           }) == snakeBody.end()) {
                possiblePositions.push_back(pos);
            }
        }
    }
    
    // Если нет возможных позиций, используем стандартный респаун
    if (possiblePositions.empty()) {
        respawn(width, height, snake);
        return;
    }
    
    // Находим позицию, максимально удаленную от головы змейки
    Position bestPos = possiblePositions[0];
    double maxDistance = 0.0;
    
    for (const Position &pos : possiblePositions) {
        // Вычисляем расстояние от головы змейки до данной позиции
        double distance = std::sqrt(std::pow(pos.x - headPos.x, 2) +
                                   std::pow(pos.y - headPos.y, 2));
        
        // Если это расстояние больше максимального, обновляем максимум
        if (distance > maxDistance) {
            maxDistance = distance;
            bestPos = pos;
        }
    }
    
    // Устанавливаем новую позицию еды
    _position = bestPos;
}

void Food::setPosition(const Position& pos) {
    _position = pos;
} 