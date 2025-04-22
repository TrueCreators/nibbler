#include "SDLGraphicsLib.hpp"
#include <iostream>

SDLGraphicsLib::SDLGraphicsLib()
    : _window(nullptr)
    , _renderer(nullptr)
    , _font(nullptr)
    , _width(0)
    , _height(0)
    , _cellSize(20)
    , _frameDelay(100)
    , _snakeHeadTexture(nullptr)
    , _snakeBodyTexture(nullptr)
    , _foodTexture(nullptr)
    , _wallTexture(nullptr)
    , _mouseX(0)
    , _mouseY(0)
    , _isWindowOpen(true)
{
    // Инициализация цветов
    _backgroundColor = {0, 0, 0, 255};      // Черный
    _snakeColor = {0, 255, 0, 255};         // Зеленый
    _foodColor = {255, 0, 0, 255};          // Красный
    _wallColor = {128, 128, 128, 255};      // Серый
    _menuBackgroundColor = {20, 20, 50, 255}; // Темно-синий
    _buttonColor = {70, 70, 120, 255};      // Темно-фиолетовый
    _buttonHoverColor = {100, 100, 180, 255}; // Светло-фиолетовый
    _buttonSelectedColor = {120, 120, 220, 255}; // Ярко-фиолетовый
    _textColor = {255, 255, 255, 255};      // Белый
}

SDLGraphicsLib::~SDLGraphicsLib() {
    cleanup();
}

bool SDLGraphicsLib::init(int width, int height, const std::string &title) {
    _width = width;
    _height = height;
    
    // Инициализация SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL не смог инициализироваться! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    // Инициализация SDL_image
    if (!(IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG)) {
        std::cerr << "Ошибка инициализации SDL_image: " << IMG_GetError() << std::endl;
        SDL_Quit();
        return false;
    }
    
    // Инициализация SDL_ttf
    if (TTF_Init() == -1) {
        std::cerr << "SDL_ttf не смог инициализироваться! SDL_ttf Error: " << TTF_GetError() << std::endl;
        IMG_Quit();
        SDL_Quit();
        return false;
    }
    
    // Создание окна
    _window = SDL_CreateWindow(
        title.c_str(),
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        _width * _cellSize, _height * _cellSize,
        SDL_WINDOW_SHOWN
    );
    
    if (!_window) {
        std::cerr << "Окно не может быть создано! SDL_Error: " << SDL_GetError() << std::endl;
        TTF_Quit();
        IMG_Quit();
        SDL_Quit();
        return false;
    }
    
    // Создание рендерера
    _renderer = SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED);
    if (!_renderer) {
        std::cerr << "Рендерер не может быть создан! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(_window);
        TTF_Quit();
        IMG_Quit();
        SDL_Quit();
        return false;
    }
    
    // Загрузка шрифта
    _font = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24);
    if (!_font) {
        std::cerr << "Не удалось загрузить шрифт! SDL_ttf Error: " << TTF_GetError() << std::endl;
        return false;
    }
    
    // Создание текстур
    createTextures();
    
    return true;
}

void SDLGraphicsLib::createTextures() {
    SDL_Surface *headSurface = SDL_CreateRGBSurface(0, _cellSize, _cellSize, 32, 0, 0, 0, 0);
    SDL_FillRect(headSurface, NULL, SDL_MapRGBA(headSurface->format, 
                                            _snakeColor.r, _snakeColor.g, _snakeColor.b, _snakeColor.a));
    _snakeHeadTexture = SDL_CreateTextureFromSurface(_renderer, headSurface);
    SDL_FreeSurface(headSurface);

    SDL_Surface *bodySurface = SDL_CreateRGBSurface(0, _cellSize - 2, _cellSize - 2, 32, 0, 0, 0, 0);
    SDL_FillRect(bodySurface, NULL, SDL_MapRGBA(bodySurface->format, 
                                            _snakeColor.r, _snakeColor.g, _snakeColor.b, _snakeColor.a));
    _snakeBodyTexture = SDL_CreateTextureFromSurface(_renderer, bodySurface);
    SDL_FreeSurface(bodySurface);

    SDL_Surface *foodSurface = SDL_CreateRGBSurface(0, _cellSize - 4, _cellSize - 4, 32, 0, 0, 0, 0);
    SDL_FillRect(foodSurface, NULL, SDL_MapRGBA(foodSurface->format, 
                                            _foodColor.r, _foodColor.g, _foodColor.b, _foodColor.a));
    _foodTexture = SDL_CreateTextureFromSurface(_renderer, foodSurface);
    SDL_FreeSurface(foodSurface);

    SDL_Surface *wallSurface = SDL_CreateRGBSurface(0, _cellSize, _cellSize, 32, 0, 0, 0, 0);
    SDL_FillRect(wallSurface, NULL, SDL_MapRGBA(wallSurface->format, 
                                            _wallColor.r, _wallColor.g, _wallColor.b, _wallColor.a));
    _wallTexture = SDL_CreateTextureFromSurface(_renderer, wallSurface);
    SDL_FreeSurface(wallSurface);
}

void SDLGraphicsLib::destroyTextures() {
    if (_snakeHeadTexture) {
        SDL_DestroyTexture(_snakeHeadTexture);
        _snakeHeadTexture = nullptr;
    }
    
    if (_snakeBodyTexture) {
        SDL_DestroyTexture(_snakeBodyTexture);
        _snakeBodyTexture = nullptr;
    }
    
    if (_foodTexture) {
        SDL_DestroyTexture(_foodTexture);
        _foodTexture = nullptr;
    }
    
    if (_wallTexture) {
        SDL_DestroyTexture(_wallTexture);
        _wallTexture = nullptr;
    }
}

void SDLGraphicsLib::cleanup() {
    // Освобождаем все шрифты
    for (auto& pair : _fonts) {
        if (pair.second) {
            TTF_CloseFont(pair.second);
        }
    }
    _fonts.clear();
    
    if (_font) {
        TTF_CloseFont(_font);
        _font = nullptr;
    }
    
    if (_renderer) {
        SDL_DestroyRenderer(_renderer);
        _renderer = nullptr;
    }
    
    if (_window) {
        SDL_DestroyWindow(_window);
        _window = nullptr;
    }
    
    TTF_Quit();
    SDL_Quit();
}

void SDLGraphicsLib::drawSnake(int x, int y, Direction dir) {
    // Рисуем основу головы змейки
    SDL_Rect rect = {x * _cellSize, y * _cellSize, _cellSize, _cellSize};
    SDL_RenderCopy(_renderer, _snakeHeadTexture, NULL, &rect);
    
    // Добавляем глаза для головы змейки в зависимости от направления
    SDL_Rect eyeRect1, eyeRect2;
    int eyeSize = _cellSize / 5;
    
    // Позиции глаз зависят от направления головы
    switch (dir) {
        case Direction::UP:
            eyeRect1 = {x * _cellSize + _cellSize / 4, y * _cellSize + _cellSize / 4, eyeSize, eyeSize};
            eyeRect2 = {x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4, eyeSize, eyeSize};
            break;
        case Direction::DOWN:
            eyeRect1 = {x * _cellSize + _cellSize / 4, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize};
            eyeRect2 = {x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize};
            break;
        case Direction::LEFT:
            eyeRect1 = {x * _cellSize + _cellSize / 4, y * _cellSize + _cellSize / 4, eyeSize, eyeSize};
            eyeRect2 = {x * _cellSize + _cellSize / 4, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize};
            break;
        case Direction::RIGHT:
            eyeRect1 = {x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + _cellSize / 4, eyeSize, eyeSize};
            eyeRect2 = {x * _cellSize + 3 * _cellSize / 4 - eyeSize, y * _cellSize + 3 * _cellSize / 4 - eyeSize, eyeSize, eyeSize};
            break;
    }
    
    // Рисуем глаза
    SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 255); // Белый цвет для глаз
    SDL_RenderFillRect(_renderer, &eyeRect1);
    SDL_RenderFillRect(_renderer, &eyeRect2);
}

void SDLGraphicsLib::drawSnakeSection(int x, int y) {
    SDL_Rect rect = {x * _cellSize + 1, y * _cellSize + 1, _cellSize - 2, _cellSize - 2};
    SDL_RenderCopy(_renderer, _snakeBodyTexture, NULL, &rect);
}

void SDLGraphicsLib::drawFood(int x, int y) {
    SDL_Rect rect = {x * _cellSize + 2, y * _cellSize + 2, _cellSize - 4, _cellSize - 4};
    SDL_RenderCopy(_renderer, _foodTexture, NULL, &rect);
}

void SDLGraphicsLib::drawWall(int x, int y) {
    SDL_Rect rect = {x * _cellSize, y * _cellSize, _cellSize, _cellSize};
    SDL_RenderCopy(_renderer, _wallTexture, NULL, &rect);
}

void SDLGraphicsLib::clearScreen() {
    if (!_renderer) {
        return;
    }
    
    SDL_SetRenderDrawColor(_renderer, _backgroundColor.r, _backgroundColor.g, _backgroundColor.b, _backgroundColor.a);
    SDL_RenderClear(_renderer);
}

void SDLGraphicsLib::updateScreen() {
    if (!_renderer) {
        return;
    }
    
    SDL_RenderPresent(_renderer);
    SDL_Delay(_frameDelay);
}

KeyPress SDLGraphicsLib::getInput() {
    SDL_Event event;
    
    // Обновляем позицию мыши
    SDL_GetMouseState(&_mouseX, &_mouseY);
    
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            return KeyPress::ESC;
        }
        
        if (event.type == SDL_KEYDOWN) {
            switch (event.key.keysym.sym) {
                case SDLK_UP:
                    return KeyPress::UP;
                case SDLK_DOWN:
                    return KeyPress::DOWN;
                case SDLK_LEFT:
                    return KeyPress::LEFT;
                case SDLK_RIGHT:
                    return KeyPress::RIGHT;
                case SDLK_1:
                    return KeyPress::ONE;
                case SDLK_2:
                    return KeyPress::TWO;
                case SDLK_3:
                    return KeyPress::THREE;
                case SDLK_r:
                    return KeyPress::RESTART;
                case SDLK_RETURN:
                    return KeyPress::ENTER;
                case SDLK_ESCAPE:
                    return KeyPress::ESC;
                default:
                    break;
            }
        }
        
        if (event.type == SDL_MOUSEBUTTONDOWN) {
            if (event.button.button == SDL_BUTTON_LEFT) {
                return KeyPress::MOUSE_LEFT;
            }
        }
    }
    
    return KeyPress::NONE;
}

bool SDLGraphicsLib::isWindowOpen() {
    return _window != nullptr;
}

void SDLGraphicsLib::setFrameDelay(int ms) {
    _frameDelay = ms;
}

TTF_Font* SDLGraphicsLib::getFont(int fontSize) {
    // Проверяем, есть ли шрифт нужного размера в кэше
    auto it = _fonts.find(fontSize);
    if (it != _fonts.end()) {
        return it->second;
    }
    
    // Если нет, создаем новый шрифт
    TTF_Font* font = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", fontSize);
    if (font) {
        _fonts[fontSize] = font;
        return font;
    }
    
    std::cerr << "Не удалось создать шрифт размера " << fontSize << std::endl;
    return nullptr;
}

void SDLGraphicsLib::drawText(const std::string &text, int x, int y, int fontSize, bool isCentered) {
    if (!_renderer || text.empty()) return;
    
    TTF_Font* font = getFont(fontSize);
    if (!font) return;
    
    SDL_Color textColor = {255, 255, 255, 255};
    SDL_Surface* textSurface = TTF_RenderText_Blended(font, text.c_str(), textColor);
    if (textSurface) {
        SDL_Texture* textTexture = SDL_CreateTextureFromSurface(_renderer, textSurface);
        if (textTexture) {
            SDL_Rect destRect;
            destRect.w = textSurface->w;
            destRect.h = textSurface->h;
            
            if (isCentered) {
                destRect.x = x - destRect.w / 2;
                destRect.y = y - destRect.h / 2;
            } else {
                destRect.x = x;
                destRect.y = y;
            }
            
            SDL_RenderCopy(_renderer, textTexture, NULL, &destRect);
            SDL_DestroyTexture(textTexture);
        }
        SDL_FreeSurface(textSurface);
    }
}

bool SDLGraphicsLib::drawButton(const std::string &text, int x, int y, int width, int height, bool isSelected, int fontSize) {
    if (!_renderer) return false;
    
    // Получаем позицию мыши
    int mouseX, mouseY;
    SDL_GetMouseState(&mouseX, &mouseY);
    
    // Проверяем, находится ли мышь над кнопкой
    bool isHovered = (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height);
    
    // Рисуем фон кнопки
    SDL_Rect buttonRect = {x, y, width, height};
    if (isSelected || isHovered) {
        SDL_SetRenderDrawColor(_renderer, 100, 100, 100, 255); // Серый цвет для выделенной кнопки
    } else {
        SDL_SetRenderDrawColor(_renderer, 50, 50, 50, 255); // Темно-серый цвет для обычной кнопки
    }
    SDL_RenderFillRect(_renderer, &buttonRect);
    
    // Рисуем рамку кнопки
    SDL_SetRenderDrawColor(_renderer, 200, 200, 200, 255);
    SDL_RenderDrawRect(_renderer, &buttonRect);
    
    // Рисуем текст по центру кнопки
    drawText(text, x + width/2, y + height/2, fontSize, true);
    
    return isHovered;
}

void SDLGraphicsLib::getMousePosition(int &x, int &y) {
    x = _mouseX;
    y = _mouseY;
}

void SDLGraphicsLib::drawMenuBackground() {
    // Create semi-transparent overlay
    SDL_SetRenderDrawBlendMode(_renderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 128); // Black with 50% opacity
    SDL_Rect overlay = {0, 0, getWindowWidth(), getWindowHeight()};
    SDL_RenderFillRect(_renderer, &overlay);
    SDL_SetRenderDrawBlendMode(_renderer, SDL_BLENDMODE_NONE);
}

// Экспортируемые функции C для создания и удаления экземпляра
extern "C" {
    IGraphicsLib* create() {
        return new SDLGraphicsLib();
    }
    
    void destroy(IGraphicsLib* instance) {
        delete instance;
    }
} 