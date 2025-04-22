NAME = ../../lib_nibbler_raylib.so
CXX = g++
CXXFLAGS = -Wall -Wextra -Werror -std=c++11 -fPIC
INCLUDES = -I../../includes
LIBS = -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
SRC = RaylibGraphicsLib.cpp
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