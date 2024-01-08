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

Memgraph graph style:

```json
@NodeStyle {
  size: 3
  label: Property(node, "name")
  border-width: 1
  border-color: #ffffff
  shadow-color: #333333
  shadow-size: 20
}

@EdgeStyle {
  width: 0.4
  label: Type(edge)
  arrow-size: 1
  color: #6AA84F
}
```

Geh whole graph:

```json
MATCH p=(n)-[r]-(m)
RETURN *;
```

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
