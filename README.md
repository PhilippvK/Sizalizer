# SEAL

## Build Custom LLVM

```sh
$   docker build . -t seal
```

### Reuse build artifacts across builds

```sh
$       docker build . -t seal -f Devbox.dockerfile
$       docker run -it -v /my/buildcache:/llvm-project/build seal
[seal]$ ./compile_llvm.sh (--clean)
```

## LLVM Changes

- Added custom RISCV MachineFunctionPass that prints out all instructions (only works on -O1 and above)

      $# /llvm-project/build/bin/clang example.c -o example -nostdlib -O3                         
      %0:gpr = ADDI $x0, 2
      $x10 = COPY %0:gpr
      PseudoRET implicit $x10

## FAQ

- How do I show currently active passes?
    - `clang -mllvm -debug-pass=Structure`
