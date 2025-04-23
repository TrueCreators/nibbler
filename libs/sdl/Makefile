NAME = ../../lib_nibbler_sdl.so
CXX = g++
CXXFLAGS = -Wall -Wextra -Werror -std=c++11 -fPIC
INCLUDES = -I../../includes -I./include/SDL2
LIBS = -L./lib -lSDL2 -lSDL2_image -lSDL2_ttf
SRC = SDLGraphicsLib.cpp
OBJ = $(SRC:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CXX) -shared -o $(NAME) $(OBJ) $(LIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re 