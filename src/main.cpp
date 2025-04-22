#include <iostream>
#include <vector>
#include <string>
#include <stdexcept>
#include "../includes/Game.hpp"

void displayUsage(const std::string &programName) {
    std::cerr << "Использование: " << programName << " <ширина> <высота>" << std::endl;
    std::cerr << "  <ширина>  - ширина игрового поля (от 10 до 100)" << std::endl;
    std::cerr << "  <высота>  - высота игрового поля (от 10 до 100)" << std::endl;
}

bool isNumeric(const std::string &str) {
    return !str.empty() && str.find_first_not_of("0123456789") == std::string::npos;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        displayUsage(argv[0]);
        return 1;
    }

    std::string widthStr = argv[1];
    std::string heightStr = argv[2];

    // Проверяем, что аргументы являются числами
    if (!isNumeric(widthStr) || !isNumeric(heightStr)) {
        std::cerr << "Ошибка: ширина и высота должны быть положительными числами." << std::endl;
        displayUsage(argv[0]);
        return 1;
    }

    int width = std::stoi(widthStr);
    int height = std::stoi(heightStr);

    // Проверяем диапазоны значений
    if (width < 10 || width > 100 || height < 10 || height > 100) {
        std::cerr << "Ошибка: ширина и высота должны быть в диапазоне от 10 до 100." << std::endl;
        displayUsage(argv[0]);
        return 1;
    }

    // Пути к динамическим библиотекам
    std::vector<std::string> libPaths = {
        "./lib_nibbler_sdl.so",
        "./lib_nibbler_raylib.so",
        "./lib_nibbler_sfml.so"
    };

    try {
        // Создаем и запускаем игру
        Game game(width, height, libPaths);
        game.run();
        
        return 0;
    } catch (const std::exception &e) {
        std::cerr << "Ошибка: " << e.what() << std::endl;
        return 1;
    }
} 