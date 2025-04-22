NAME = nibbler
CXX = g++
CXXFLAGS = -Wall -Wextra -Werror -std=c++11 -fPIC
INCLUDES = -I./includes
SRC_PATH = ./src
LIB_PATH = ./libs
OBJ_PATH = ./obj
BIN_PATH = ./

SDL_DIR = $(LIB_PATH)/sdl
RAYLIB_DIR = $(LIB_PATH)/raylib
SFML_DIR = $(LIB_PATH)/sfml

SRCS = $(SRC_PATH)/main.cpp \
	   $(SRC_PATH)/Game.cpp \
	   $(SRC_PATH)/Snake.cpp \
	   $(SRC_PATH)/Food.cpp \
	   $(SRC_PATH)/DynamicLoader.cpp \
	   $(SRC_PATH)/Menu.cpp

OBJS = $(patsubst $(SRC_PATH)/%.cpp, $(OBJ_PATH)/%.o, $(SRCS))

SDL_LIB = $(BIN_PATH)/lib_nibbler_sdl.so
RAYLIB_LIB = $(BIN_PATH)/lib_nibbler_raylib.so
SFML_LIB = $(BIN_PATH)/lib_nibbler_sfml.so

all: setup $(NAME) $(SDL_LIB) $(RAYLIB_LIB) $(SFML_LIB)

setup:
	@mkdir -p $(OBJ_PATH)

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(OBJS) -o $(BIN_PATH)/$(NAME) -ldl

$(SDL_LIB):
	$(MAKE) -C $(SDL_DIR)

$(RAYLIB_LIB):
	$(MAKE) -C $(RAYLIB_DIR)

$(SFML_LIB):
	$(MAKE) -C $(SFML_DIR)

clean:
	rm -rf $(OBJ_PATH)
	$(MAKE) -C $(SDL_DIR) clean
	$(MAKE) -C $(RAYLIB_DIR) clean
	$(MAKE) -C $(SFML_DIR) clean

fclean: clean
	rm -f $(BIN_PATH)/$(NAME)
	rm -f $(SDL_LIB)
	rm -f $(RAYLIB_LIB)
	rm -f $(SFML_LIB)
	$(MAKE) -C $(SDL_DIR) fclean
	$(MAKE) -C $(RAYLIB_DIR) fclean
	$(MAKE) -C $(SFML_DIR) fclean

re: fclean all

.PHONY: all setup clean fclean re 