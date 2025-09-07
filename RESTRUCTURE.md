# Project Restructure Plan (Phase 1: Directory Layout)

> Goal: create a clean, modern layout with minimal code changes first. We’ll refactor scripts in Phase 2.

## 1) Target Layout

```
.
├─ CMakeLists.txt
├─ README.md
├─ LICENSE                 # keep original; we’ll revisit after license convo
├─ NOTICE                  # add later in Phase 2
├─ .gitignore
├─ .editorconfig
├─ .gitattributes
├─ .clang-format
├─ .clang-tidy
├─ cmake/                  # cmake helpers (toolchain, options, etc.)
├─ include/                # public headers (installed)
│  └─ alpacapi/            # library-facing headers
├─ src/                    # library sources (non-public)
│  ├─ core/
│  ├─ net/
│  ├─ proto/
│  └─ util/
├─ drivers/                # device adapters (e.g., iOptron, ZWO power, etc.)
├─ examples/               # minimal runnable examples
├─ tests/                  # unit/integration tests (Phase 2)
├─ scripts/                # build/run/install utilities (Phase 2 cleanup)
└─ docs/                   # doxygen/mkdocs (Phase 2)
```

> Keep file headers + copyright lines intact.

## 2) Create Baseline Files/Dirs

**Create scaffolding**
```bash
mkdir -p cmake include/alpacapi src/{core,net,proto,util} drivers examples tests scripts docs
touch .editorconfig .gitattributes .clang-format .clang-tidy
```

**.gitignore**
```gitignore
# build/ artifacts
/build/
/out/
/dist/
/.install/

/.vscode/
/.idea/
/cmake-build-*/
*.cache
*.obj
*.o
*.a
*.so
*.dll
*.dylib
*.exe
```

**.editorconfig**
```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
```

**.clang-format**
```yaml
BasedOnStyle: LLVM
IndentWidth: 2
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: Empty
DerivePointerAlignment: false
PointerAlignment: Left
SortIncludes: true
```

**.clang-tidy**
```yaml
Checks: >
  bugprone-*,performance-*,readability-*,modernize-*,
  cppcoreguidelines-*,clang-analyzer-*
WarningsAsErrors: ['bugprone-*','clang-analyzer-*']
HeaderFilterRegex: '^(include|src|drivers)/'
FormatStyle: none
```

Commit the scaffolding:
```bash
git add .
git commit -m "chore(layout): add baseline directories and tooling configs"
```

## 3) Move Code Into New Structure (history-preserving)

> Use `git mv` where possible to keep history. If you’re unsure where a file belongs, prefer `src/core` for now; we can reclassify later.

Examples (adjust globs/paths to match the current repo):
```bash
# Public headers
git mv old_include/*.h include/alpacapi/ 2>/dev/null || true

# Core sources
git mv src/*.cpp src/core/ 2>/dev/null || true
git mv source/*.cpp src/core/ 2>/dev/null || true
git mv lib/*.cpp src/core/ 2>/dev/null || true
git mv lib/*.c src/core/ 2>/dev/null || true
git mv include/*.h src/core/ 2>/dev/null || true

# Protocol / networking
git mv src/*proto*.{c,cpp,h,hpp} src/proto/ 2>/dev/null || true
git mv src/*net*.{c,cpp,h,hpp}   src/net/   2>/dev/null || true
git mv src/*util*.{c,cpp,h,hpp}  src/util/  2>/dev/null || true

# Drivers
mkdir -p drivers/ioptron drivers/zwopower
git mv drivers_ioptron/* drivers/ioptron/ 2>/dev/null || true
git mv zwopower/*       drivers/zwopower/ 2>/dev/null || true

# Examples
git mv examples_* examples/ 2>/dev/null || true
git mv demo/*     examples/ 2>/dev/null || true
```

Commit:
```bash
git add -A
git commit -m "refactor(tree): move sources into include/src/drivers/examples layout (no code changes)"
```

## 4) Minimal CMake (build without logical refactors)

**CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.20)
project(AlpacaPi VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLES "Build examples" ON)

file(GLOB_RECURSE ALPACAPI_PUBLIC_HEADERS
  CONFIGURE_DEPENDS
  "${CMAKE_SOURCE_DIR}/include/alpacapi/*.h"
  "${CMAKE_SOURCE_DIR}/include/alpacapi/*.hpp"
)

file(GLOB_RECURSE ALPACAPI_SOURCES
  CONFIGURE_DEPENDS
  "${CMAKE_SOURCE_DIR}/src/**/*.c"
  "${CMAKE_SOURCE_DIR}/src/**/*.cpp"
)

add_library(alpacapi ${ALPACAPI_SOURCES} ${ALPACAPI_PUBLIC_HEADERS})
target_include_directories(alpacapi
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_compile_features(alpacapi PUBLIC cxx_std_17)

if (BUILD_EXAMPLES)
  add_executable(example_discover examples/example_discover.cpp)
  target_link_libraries(example_discover PRIVATE alpacapi)
endif()
```

Build:
```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
```

Commit:
```bash
git add CMakeLists.txt
git commit -m "build(cmake): add minimal top-level CMake to build library and example"
```

## 5) README: New Structure Note

Append to `README.md`:
```md
## New Directory Structure (Phase 1)

This fork reorganizes the project to a modern layout:

- `include/alpacapi/` — public headers
- `src/` — internal sources (core, net, proto, util)
- `drivers/` — device adapters
- `examples/` — minimal runnable examples
- `scripts/` — tooling (to be cleaned in Phase 2)
- `tests/` — unit/integration tests (Phase 2)
- `docs/` — documentation (Phase 2)

> No functional changes in Phase 1 — this is a tree-only refactor.
```

Commit:
```bash
git add README.md
git commit -m "docs: document Phase 1 directory structure"
```

## 6) Sanity Checks

- Build in Debug:
```bash
cmake -S . -B build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build-debug -j
```

- Run example:
```bash
./build/examples/example_discover || true
```

## 7) PR & Tag

- Open a PR from `openastro-main` to your fork’s default branch, or set `openastro-main` as default.  
- Tag prerelease once green:
```bash
git tag -a v0.1.0-tree -m "Phase 1: directory restructure only"
git push --tags
```

---

## Next: Phase 2 (Scripts Cleanup)

We’ll standardize bash scripts with safety flags, logging, usage help, add pre-commit hooks, and wire CI. Hold until licensing outcome is confirmed.
