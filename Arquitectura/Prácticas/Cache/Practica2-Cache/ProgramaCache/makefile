CC = gcc
CFLAGS = -I.
DEPS = main.h cache.h

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) -lm

sim: main.c cache.c
	$(CC) -o $@ $^ $(CFLAGS) -lm
