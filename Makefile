TCL_DIR=/usr/include/tcl8.5
LIB_DIR=/usr/lib
TCL_LIB=tcl8.5

TCL_INCLUDES=-I$(TCL_DIR)

CC=gcc
CFLAGS=-shared -Wall
DFLAGS=-DHAVE_CONFIG_H
LINKS=-l$(TCL_LIB) -L$(LIB_DIR)
INCLUDES=-I. $(TCL_INCLUDES)

OBJS=blowfish.o

all: libfish.so

libfish.so: $(OBJS) module.c
	$(CC) module.c $(LINKS) $(INCLUDES) $(CFLAGS) $(OBJS) -o $@ $(DFLAGS) $(DEBUG)

%.o: %.c %.h
	$(CC) $(INCLUDES) $(CFLAGS) -c $(DFLAGS) -o $@ $< $(DEBUG)

clean:
	rm -f libfish.so $(OBJS)
