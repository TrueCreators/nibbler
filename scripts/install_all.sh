#!/bin/bash

# Один скрипт для установки всех библиотек для Nibbler
echo "Установка библиотек для Nibbler..."

# Директории для установки
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
LIBS_DIR="$PROJECT_ROOT/libs"
SDL_DIR="$LIBS_DIR/sdl"
GLFW_DIR="$LIBS_DIR/glfw"
RAYLIB_DIR="$LIBS_DIR/raylib"
SFML_DIR="$LIBS_DIR/sfml"

# Создаем директории
mkdir -p "$SDL_DIR" "$GLFW_DIR" "$RAYLIB_DIR" "$SFML_DIR"

# Установка SDL2
install_sdl() {
  echo "Установка SDL2..."
  
  # Создаем директории
  mkdir -p "$SDL_DIR/build" "$SDL_DIR/include" "$SDL_DIR/lib"
  
  # Скачиваем SDL2
  wget -q -O "$SDL_DIR/SDL2.tar.gz" https://www.libsdl.org/release/SDL2-2.0.20.tar.gz
  tar -xzf "$SDL_DIR/SDL2.tar.gz" -C "$SDL_DIR/build"
  cd "$SDL_DIR/build/SDL2-2.0.20"
  
  # Компилируем и устанавливаем
  ./configure --prefix="$SDL_DIR"
  make -j$(nproc)
  make install
  
  # Скачиваем SDL2_ttf
  wget -q -O "$SDL_DIR/SDL2_ttf.tar.gz" https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.18.tar.gz
  tar -xzf "$SDL_DIR/SDL2_ttf.tar.gz" -C "$SDL_DIR/build"
  cd "$SDL_DIR/build/SDL2_ttf-2.0.18"
  
  # Компилируем и устанавливаем
  ./configure --prefix="$SDL_DIR" --with-sdl-prefix="$SDL_DIR"
  make -j$(nproc)
  make install
  
  echo "SDL2 установлен успешно"
}

# Установка GLFW и Raylib
install_raylib() {
  echo "Установка GLFW и Raylib..."
  
  # Создаем директории
  mkdir -p "$GLFW_DIR/build" "$GLFW_DIR/include" "$GLFW_DIR/lib"
  mkdir -p "$RAYLIB_DIR/build" "$RAYLIB_DIR/include" "$RAYLIB_DIR/lib"
  
  # Устанавливаем GLFW
  git clone -q https://github.com/glfw/glfw.git --branch 3.3.8 --depth 1 "$GLFW_DIR/build/glfw"
  mkdir -p "$GLFW_DIR/build/glfw/build"
  cd "$GLFW_DIR/build/glfw/build"
  
  cmake -DCMAKE_INSTALL_PREFIX="$GLFW_DIR" \
        -DBUILD_SHARED_LIBS=ON \
        -DGLFW_BUILD_EXAMPLES=OFF \
        -DGLFW_BUILD_TESTS=OFF \
        -DGLFW_BUILD_DOCS=OFF \
        ..
  make -j$(nproc)
  make install
  
  # Устанавливаем Raylib
  git clone -q https://github.com/raysan5/raylib.git --branch '3.0.0' --depth 1 "$RAYLIB_DIR/build/raylib"
  mkdir -p "$RAYLIB_DIR/build/raylib/build"
  cd "$RAYLIB_DIR/build/raylib/build"
  
  cmake -DCMAKE_INSTALL_PREFIX="$RAYLIB_DIR" \
        -DBUILD_SHARED_LIBS=ON \
        -DUSE_EXTERNAL_GLFW=ON \
        -DGLFW_INCLUDE_DIRS="$GLFW_DIR/include" \
        -DGLFW_LIBRARY="$GLFW_DIR/lib/libglfw.so" \
        ..
  make -j$(nproc)
  make install
  
  echo "GLFW и Raylib установлены успешно"
}

# Установка SFML
install_sfml() {
  echo "Установка SFML..."
  
  # Создаем директории
  mkdir -p "$SFML_DIR/build" "$SFML_DIR/include" "$SFML_DIR/lib"
  
  # Скачиваем SFML
  git clone -q https://github.com/SFML/SFML.git --branch 2.5.1 --depth 1 "$SFML_DIR/build/sfml"
  mkdir -p "$SFML_DIR/build/sfml/build"
  cd "$SFML_DIR/build/sfml/build"
  
  # Собираем SFML
  cmake -DCMAKE_INSTALL_PREFIX="$SFML_DIR" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        ..
  make -j$(nproc)
  make install
  
  echo "SFML установлен успешно"
}

# Обновление Makefile
update_makefile() {
  echo "Обновление Makefile..."
  
  # Создаем резервную копию
  cp "$PROJECT_ROOT/Makefile" "$PROJECT_ROOT/Makefile.bak"
  
  # Обновляем пути к библиотекам в Makefile
  sed -i "s|SDL_PATH[ \t]*=.*|SDL_PATH = $SDL_DIR|g" "$PROJECT_ROOT/Makefile"
  sed -i "s|RAYLIB_PATH[ \t]*=.*|RAYLIB_PATH = $RAYLIB_DIR|g" "$PROJECT_ROOT/Makefile"
  sed -i "s|SFML_PATH[ \t]*=.*|SFML_PATH = $SFML_DIR|g" "$PROJECT_ROOT/Makefile"
  
  echo "Makefile обновлен"
}

# Компиляция проекта
compile_project() {
  echo "Компиляция проекта Nibbler..."
  cd "$PROJECT_ROOT"
  make clean
  make -j$(nproc)
  
  if [ $? -eq 0 ]; then
    echo "Проект успешно скомпилирован"
  else
    echo "Ошибка при компиляции проекта"
  fi
}

# Запуск функций установки
install_sdl
install_raylib
install_sfml
update_makefile
compile_project

echo "Установка завершена. Теперь можно запускать: ./nibbler ШИРИНА ВЫСОТА" 