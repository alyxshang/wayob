# WAYOB by Alyx Shang.
# Licensed under the FSL v1.

.PHONY: all

all:	build test clean lint

build:
	clang -shared clib/libadd.c -I clib/ -o libadd

test: 	build
	zig build test --summary all

clean:	test
	rm -rf libadd zig-out .zig-cache

lint:
	zlint
