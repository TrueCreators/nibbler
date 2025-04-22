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
    Direction snakeDirection = snake.getDirection();
    
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
    
    // В режиме убегающей еды мы будем учитывать не только расстояние,
    // но и направление движения змейки, чтобы еда появлялась "впереди" и заставляла змейку двигаться
    
    // Находим позиции вдали от головы змейки, но предпочтительно в противоположном направлении движения
    std::vector<std::pair<Position, double>> scoredPositions;
    
    for (const Position &pos : possiblePositions) {
        // Вычисляем расстояние от головы змейки до данной позиции
        double distance = std::sqrt(std::pow(pos.x - headPos.x, 2) + std::pow(pos.y - headPos.y, 2));
        
        // Вычисляем фактор направления (приоритизируем позиции в направлении, противоположном движению змейки)
        double directionFactor = 1.0;
        
        // Проверяем позицию относительно направления движения змейки
        switch (snakeDirection) {
            case Direction::UP:
                // Если змейка движется вверх, приоритизируем позиции внизу
                directionFactor = (pos.y > headPos.y) ? 1.5 : 1.0;
                break;
            case Direction::DOWN:
                // Если змейка движется вниз, приоритизируем позиции вверху
                directionFactor = (pos.y < headPos.y) ? 1.5 : 1.0;
                break;
            case Direction::LEFT:
                // Если змейка движется влево, приоритизируем позиции справа
                directionFactor = (pos.x > headPos.x) ? 1.5 : 1.0;
                break;
            case Direction::RIGHT:
                // Если змейка движется вправо, приоритизируем позиции слева
                directionFactor = (pos.x < headPos.x) ? 1.5 : 1.0;
                break;
        }
        
        // Учитываем близость к стенам (избегаем углов)
        double wallFactor = 1.0;
        if ((pos.x <= 2 || pos.x >= width - 3) && (pos.y <= 2 || pos.y >= height - 3)) {
            wallFactor = 0.7; // Снижаем приоритет углов
        }
        
        // Вычисляем итоговый счет для позиции
        double score = distance * directionFactor * wallFactor;
        
        scoredPositions.push_back({pos, score});
    }
    
    // Сортируем позиции по убыванию счета
    std::sort(scoredPositions.begin(), scoredPositions.end(), 
              [](const std::pair<Position, double> &a, const std::pair<Position, double> &b) {
                  return a.second > b.second; 
              });
    
    // Выбираем одну из трех лучших позиций (если есть)
    std::uniform_int_distribution<int> dist(0, std::min(2, static_cast<int>(scoredPositions.size()) - 1));
    int index = dist(_rng);
    
    // Устанавливаем новую позицию еды
    _position = scoredPositions[index].first;
}

void Food::setPosition(const Position& pos) {
    _position = pos;
} 