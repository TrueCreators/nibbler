#ifndef SFMLGRAPHICSLIB_HPP
#define SFMLGRAPHICSLIB_HPP

#include "../../includes/IGraphicsLib.hpp"
#include <SFML/Graphics.hpp>

class SFMLGraphicsLib : public IGraphicsLib {
private:
    sf::RenderWindow *_window;
    int _width;
    int _height;
    int _cellSize;
    int _frameDelay;
    
    // Цвета
    sf::Color _backgroundColor;
    sf::Color _snakeColor;
    sf::Color _foodColor;
    sf::Color _wallColor;
    sf::Color _menuBackgroundColor;
    sf::Color _buttonColor;
    sf::Color _buttonHoverColor;
    sf::Color _buttonSelectedColor;
    sf::Color _textColor;
    
    // Формы для отрисовки
    sf::RectangleShape _snakeHeadShape;
    sf::RectangleShape _snakeBodyShape;
    sf::CircleShape _foodShape;
    sf::RectangleShape _wallShape;
    
    // Шрифт
    sf::Font _font;
    
    // Создание форм для отрисовки
    void createShapes();
    
    // Позиция мыши
    sf::Vector2i _mousePosition;
    
public:
    SFMLGraphicsLib();
    virtual ~SFMLGraphicsLib();
    
    // Методы IGraphicsLib
    virtual bool init(int width, int height, const std::string &title) override;
    virtual void cleanup() override;
    virtual void drawSnake(int x, int y, Direction dir) override;
    virtual void drawSnakeSection(int x, int y) override;
    virtual void drawFood(int x, int y) override;
    virtual void drawWall(int x, int y) override;
    virtual void clearScreen() override;
    virtual void updateScreen() override;
    virtual KeyPress getInput() override;
    virtual bool isWindowOpen() override;
    virtual void setFrameDelay(int ms) override;
    
    // Новые методы для UI
    virtual void drawText(const std::string &text, int x, int y, int fontSize, bool isCentered = false) override;
    virtual bool drawButton(const std::string &text, int x, int y, int width, int height, bool isSelected = false, int fontSize = 20) override;
    virtual void getMousePosition(int &x, int &y) override;
    virtual void drawMenuBackground() override;
    
    // Методы для получения размеров окна и ячейки
    virtual int getWindowWidth() const override { return _width * _cellSize; }
    virtual int getWindowHeight() const override { return _height * _cellSize; }
    virtual int getCellSize() const override { return _cellSize; }
    virtual int getGridWidth() const override { return _width; }
    virtual int getGridHeight() const override { return _height; }
};

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create();
    void destroy(IGraphicsLib* instance);
}

#endif // SFMLGRAPHICSLIB_HPP 