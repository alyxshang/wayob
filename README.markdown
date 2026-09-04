# WAYOB

![Wayob CI](https://github.com/alyxshang/wayob/actions/workflows/zig.yml/badge.svg)

***A Turing-complete stack-based bytecode virtual machine.***

## ABOUT 

This repository contains the source code for a Turing-complete stack-based bytecode virtual machine written in Zig. *Wayob* is the Yucatec Maya word for a supernatural being in Mayan mythology.

## FEATURES

- Extremely fast.
- Extremely light.
- A small and lean instruction set.
- Full support for calling functions via FFI.
- A robust type system allowing for user-defined types.

## INSTALLATION

This Zig library uses Zig version `0.14.0`.
To add this library to your project, use the following command:

```Bash
zig fetch --save git+https://github.com/alyxshang/wayob.git#v.0.1.0
```

The following module must also be declared in your project's `build.zig`:

```Zig
const wayob_dep = b.dependency(
    "wayob", 
    .{
        .target = target,
        .optimize = optimize,
    }
);
your_main_module.root_module.addImport("wayob", wayob_dep.module("wayob"));
```

`your_main_module` is the module you want to add *Wayob* to.

## RUNNING TESTS

Make sure you have the following tools installed and available from the
command line: CMake, Clang, Git, ZLint for Zig v.0.14.0, and Zig v.0.14.0.

- 1.) Clone the repository:


```Bash
git clone https://github.com/alyxshang/wayob --depth=1
```

- 2.) Change directory into the repository's root:


```Bash
cd wayob
```

- 3.) Build the C library, run the tests, clean the project, and run the linter:


```Bash
make
```


## USAGE

The heart of this library is the `runInstructions` function, located in
`src/run.zig`. This function expects three arguments: i) an allocator,
ii) an `ArrayList` containing bytecode instructions, and iii) an
`ArrayList` containing the constants to run these instructions on. The
constants are of the `FrameData` type, located in `stack.zig`. This data
type unifies the following types:

- `.Bool`: Boolean values.
- `.String`: A pointer to a C-style string.
- `.Integer`: Signed integers of a maximum length of 64 bits.
- `.ExternFunction`: A function defined in a dynamic library. These external functions follow the C calling convention and must include the path to the external library they are from, the symbol name, and the number of arguments needed for the function. Any functions to be called by *Wayob* must have the following function signature: `CFrame function_name(const CFrame* list, size_t len)`. `function_name` is a placeholder for the function's name. The directory `clib` contains a C header file containing all type definitions for the `CFrame` type.
- `.Function`: A function, itself defined as a list of instructions. Functions have an `arg_count` field, that pops the number of arguments specified off the stack.
- `.FloatingPoint`: Signed decimal numbers of a maximum length of 64 bits.
- `.Structure`: An `ArrayList` containing instances of the `FrameData` type.

### INSTRUCTIONS

The list below is a comprehensive list of all the instructions *Wayob* understands.

- `ADD`: Pops the last two values off the stack, adds them, and pushes the result back onto the stack. The operation can only be done on integers and decimal numbers.
- `SUB`: Pops the last two values off the stack, subtracts them, and pushes the result back onto the stack. The operation can only be done on integers and decimal numbers.
- `DIV`: Pops the last two values off the stack, divides them, and pushes the result back onto the stack. The operation can only be done on integers and decimal numbers. If the operation is done on integers, the result is rounded down.
- `MUL`: Pops the last two values off the stack, multiplies them, and pushes the result back onto the stack. The operation can only be done on integers and decimal numbers.
- `CALL`: Attempts to fetch the function stored at the index specified in the pool of constants. The specified number of arguments is popped off the stack, stored in an `ArrayList`, and, together with the list of instructions stored in the function, handed to the `runInstructions` function. The memory allocated for the `ArrayList` of arguments is freed after the function has completed execution. The function's resulting value is pushed back onto the stack.
- `MODULO`: Pops the last two values off the stack, performs a modulo operation on them, and pushes the result back onto the stack. The operation can only be done on integers.
- `RETURN`: Pops the current frame off of the stack and returns this value.
- `JUMP_FRWD`: Increments the instruction pointer by the specified unsigned integer.
- `LOAD_CONST`: Attempts to fetch the data frame at the specified index
  in the `ArrayList` of constants and pushes this data frame onto the stack.
- `EXTERN_CALL`: Attempts to fetch the external function defined in the pool of constants at the specified index. The definition of the external function contains an absolute or relative path to the dynamic library, the symbol name for the external function, and the count of arguments the function expects. The specified number of arguments is popped off the stack and stored in an `ArrayList`. This list of arguments is owned by the external function and freed once the function has completed computing. The function's resulting value is pushed back onto the stack. 
- `COMPARE_EQ`: Pops the last two values off the stack, performs an equality comparison on them, and pushes the resulting Boolean value back onto the stack. The operation can only be done on primitive data types. This excludes external functions, functions, and structures.
- `COMPARE_GT`: Pops the last two values off the stack, performs a greater-than comparison on them, and pushes the resulting Boolean value back onto the stack. The operation can only be done on integers and decimal numbers. 
- `COMPARE_LT`: Pops the last two values off the stack, performs a less-than comparison on them, and pushes the resulting Boolean value back onto the stack. The operation can only be done on integers and decimal numbers.
- `COMPARE_NEQ`: Pops the last two values off the stack, performs an inequality comparison on them, and pushes the resulting Boolean value back onto the stack. The operation can only be done on primitive data types. This excludes external functions, functions, and structures.
- `STORE_CONST`: Pops the last value off the stack and attempts to append that value to the `ArrayList` of constants.
- `MODIFY_CONST`: Pops the last value off the stack and overwrites the value at the specified index in the pool of constants with the popped value.
- `CREATE_STRUCT`: Pops the number of values specified off the stack,
  stores them in an `ArrayList`, and appends this `ArrayList` to the
  pool of constants. 
- `JUMP_BACK_IF_TRUE`: Pops the last value off the stack and checks if it
  is a Boolean `true` value. If it is, it jumps back in the list of
  instructions by the specified offset. If the popped value is a Boolean
  `false`, the instruction counter is incremented by one.
- `JUMP_FRWD_IF_TRUE`: Pops the last value off the stack and checks if it
  is a Boolean `true` value. If it is, it jumps forward in the list of
  instructions by the specified offset. If the popped value is a Boolean
  `false`, the instruction counter is incremented by one.

To see examples of how to use this VM, it is recommended to read some of the
unit tests in [`src/tests.zig`](src/tests.zig).

More information on the entities inside this library can be obtained by cloning this repository and running the `zig build docs` command from the repository's root.

## CHANGELOG

### Version 0.1.0

- Initial release.
- Upload to GitHub.

## NOTE

- *Wayob* by *Alyx Shang*.
- Licensed under the [FSL v1](https://alyxshang.boo/fair-software-license).
