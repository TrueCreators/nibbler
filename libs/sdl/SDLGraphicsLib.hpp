#ifndef SDLGRAPHICSLIB_HPP
#define SDLGRAPHICSLIB_HPP

#include "../../includes/IGraphicsLib.hpp"
#include "./include/SDL2/SDL.h"
#include "./include/SDL2/SDL_image.h"
#include "./include/SDL2/SDL_ttf.h"
#include <map>

class SDLGraphicsLib : public IGraphicsLib {
private:
    SDL_Window* _window;
    SDL_Renderer* _renderer;
    TTF_Font* _font;
    std::map<int, TTF_Font*> _fonts; // Кэш шрифтов разных размеров
    int _width;
    int _height;
    int _cellSize;
    int _frameDelay;
    
    // Цвета
    SDL_Color _backgroundColor;
    SDL_Color _snakeColor;
    SDL_Color _foodColor;
    SDL_Color _wallColor;
    SDL_Color _menuBackgroundColor;
    SDL_Color _buttonColor;
    SDL_Color _buttonHoverColor;
    SDL_Color _buttonSelectedColor;
    SDL_Color _textColor;
    
    // Текстуры
    SDL_Texture* _snakeHeadTexture;
    SDL_Texture* _snakeBodyTexture;
    SDL_Texture* _foodTexture;
    SDL_Texture* _wallTexture;
    
    // Создание текстур
    void createTextures();
    
    // Уничтожение текстур
    void destroyTextures();
    
    // Последняя позиция мыши
    int _mouseX;
    int _mouseY;
    
    bool _isWindowOpen;
    
    // Вспомогательный метод для получения шрифта нужного размера
    TTF_Font* getFont(int fontSize);
    
public:
    SDLGraphicsLib();
    virtual ~SDLGraphicsLib();
    
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
};

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create();
    void destroy(IGraphicsLib* instance);
}

#endif // SDLGRAPHICSLIB_HPP 