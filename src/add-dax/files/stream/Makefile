GEM5_PATH = /home/gem5/gem5
ISA = x86
GXX = gcc

all: stream

stream: stream.c
	$(GXX) -o stream stream.c -lm5

clean:
	rm -f stream