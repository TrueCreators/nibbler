#ifndef RAYLIBGRAPHICSLIB_HPP
#define RAYLIBGRAPHICSLIB_HPP

#include "../../includes/IGraphicsLib.hpp"
#include "raylib.h"

class RaylibGraphicsLib : public IGraphicsLib {
private:
    int _width;
    int _height;
    int _cellSize;
    int _frameDelay;
    bool _windowOpen;
    
    // Цвета
    Color _backgroundColor;
    Color _snakeColor;
    Color _foodColor;
    Color _wallColor;
    Color _menuBackgroundColor;
    Color _buttonColor;
    Color _buttonHoverColor;
    Color _buttonSelectedColor;
    Color _textColor;
    
    // Шрифт
    Font _font;
    bool _fontLoaded;
    
    // Позиция мыши
    Vector2 _mousePosition;
    
public:
    RaylibGraphicsLib();
    virtual ~RaylibGraphicsLib();
    
    // Методы из IGraphicsLib
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
    
private:
    // ... существующие приватные члены ...
};

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create();
    void destroy(IGraphicsLib* instance);
}

#endif // RAYLIBGRAPHICSLIB_HPP 