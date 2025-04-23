NAME = libraylib.so

CC = g++
CFLAGS = -Wall -Wextra -Werror -std=c++11 -fPIC
LDFLAGS = -shared

RAYLIB_PATH = ./raylib

SRCS = RayLibGraphic.cpp

OBJS = $(SRCS:.cpp=.o)

INCLUDES = -I../../ -I$(RAYLIB_PATH)/src

.PHONY: all clean fclean re

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $(NAME) -L$(RAYLIB_PATH)/src -lraylib -lm -ldl -lpthread -lGL

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all 