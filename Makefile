# WAYOB by Alyx Shang.
# Licensed under the FSL v1.

build: ; clang -shared clib/libadd.c -I clib/ -o libadd

test: ; zig build test --summary all

clean: ; rm -rf libadd zig-out .zig-cache

lint: ; zlint
