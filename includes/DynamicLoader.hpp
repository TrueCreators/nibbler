#ifndef DYNAMICLOADER_HPP
#define DYNAMICLOADER_HPP

#include <string>
#include <stdexcept>
#include <dlfcn.h>
#include "IGraphicsLib.hpp"

class DynamicLibraryException : public std::runtime_error {
public:
    explicit DynamicLibraryException(const std::string &message) : std::runtime_error(message) {}
};

class DynamicLoader {
private:
    void *_handle;
    IGraphicsLib *_instance;
    create_t *_create;
    destroy_t *_destroy;

public:
    DynamicLoader();
    ~DynamicLoader();

    // Загрузка динамической библиотеки
    void loadLibrary(const std::string &libPath);
    
    // Выгрузка текущей библиотеки
    void unloadLibrary();
    
    // Получение экземпляра графической библиотеки
    IGraphicsLib *getInstance() const;
    
    // Проверка загружена ли библиотека
    bool isLoaded() const;
};

#endif // DYNAMICLOADER_HPP 