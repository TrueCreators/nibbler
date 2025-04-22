#ifndef POSITION_HPP
#define POSITION_HPP

struct Position {
    int x;
    int y;
    
    Position(int x = 0, int y = 0) : x(x), y(y) {}
    
    bool operator==(const Position &other) const {
        return x == other.x && y == other.y;
    }
};

#endif // POSITION_HPP 