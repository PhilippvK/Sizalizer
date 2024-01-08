# LLVM Pass Plugin

Clang/LLVM supports dynamically loaded passes as plugins.
However, these plugins can't operate on the MIR, only on the
more abstract LLVM IR.

## Dependencies

- llvm
- g++
- clang (same version as llvm)

# Setup

Build memgraph container:

```bash

      // Close DB connection
      mg_session_destroy(session);
      mg_finalize();
```

Run memgraph:

```bash
docker start memgraph
```

Web interface available at: `http://localhost:3000/`

Build pass with:

```bash
mkdir -p build
cd build
cmake ..
make
```

## Usage

```sh
$ clang -O3 -fpass-plugin=./build/libLLVMCDFG.so ...
```
