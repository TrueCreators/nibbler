#include "../includes/DynamicLoader.hpp"
#include <iostream>

DynamicLoader::DynamicLoader() : _handle(nullptr), _instance(nullptr), _create(nullptr), _destroy(nullptr) {}

DynamicLoader::~DynamicLoader() {
    unloadLibrary();
}

void DynamicLoader::loadLibrary(const std::string &libPath) {
    // Если уже есть загруженная библиотека, выгружаем её
    if (_handle) {
        unloadLibrary();
    }

    // Загрузка библиотеки
    _handle = dlopen(libPath.c_str(), RTLD_LAZY);
    if (!_handle) {
        throw DynamicLibraryException("Не удалось загрузить библиотеку: " + std::string(dlerror()));
    }

    // Получение функции создания экземпляра
    _create = reinterpret_cast<create_t *>(dlsym(_handle, "create"));
    const char *dlsym_error = dlerror();
    if (dlsym_error) {
        dlclose(_handle);
        _handle = nullptr;
        throw DynamicLibraryException("Не удалось найти функцию 'create': " + std::string(dlsym_error));
    }

    // Получение функции удаления экземпляра
    _destroy = reinterpret_cast<destroy_t *>(dlsym(_handle, "destroy"));
    dlsym_error = dlerror();
    if (dlsym_error) {
        dlclose(_handle);
        _handle = nullptr;
        throw DynamicLibraryException("Не удалось найти функцию 'destroy': " + std::string(dlsym_error));
    }

    // Создание экземпляра графической библиотеки
    _instance = _create();
    if (!_instance) {
        dlclose(_handle);
        _handle = nullptr;
        throw DynamicLibraryException("Не удалось создать экземпляр графической библиотеки");
    }
}

void DynamicLoader::unloadLibrary() {
    if (_handle) {
        if (_instance && _destroy) {
            _destroy(_instance);
            _instance = nullptr;
        }
        dlclose(_handle);
        _handle = nullptr;
        _create = nullptr;
        _destroy = nullptr;
    }
}

IGraphicsLib *DynamicLoader::getInstance() const {
    return _instance;
}

bool DynamicLoader::isLoaded() const {
    return _handle != nullptr && _instance != nullptr;
} 