#!/usr/bin/env python3
"""Compare the per-file compile flags of a waf build and a CMake build.

    ./waf configure --compile-database ... && ./waf
    cmake -S . -B build-cmake && cmake --build build-cmake
    scripts/compare-compile-commands.py build/compile_commands.json \\
        build-cmake/compile_commands.json [--external] [--files] \\
        [--ignore-define=NAME ...]

For every source file both builds compile, it diffs the -D defines, the
in-tree include directories (source and build tree, normalised so the two
build directories compare equal) and the remaining flags, and groups the
differences by source directory. --external also diffs include dirs outside
the tree (pkg-config paths); --files lists each differing file;
--ignore-define drops a define on both sides (e.g. one the waf build only has
because it was passed in CFLAGS). CMake's automatic <target>_EXPORTS defines
are always ignored. Exit status is 1 when anything differs.
"""
import json
import os
import shlex
import sys
from collections import defaultdict

TOP = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

args = sys.argv[1:]
positional = [a for a in args if not a.startswith("--")]
show_external = "--external" in args
show_files = "--files" in args
ignored_defines = {a.split("=", 1)[1] for a in args if a.startswith("--ignore-define=")}

if len(positional) != 2:
    print(__doc__, file=sys.stderr)
    sys.exit(2)


def load(path):
    build_root = os.path.dirname(os.path.abspath(path))
    db = {}
    for e in json.load(open(path)):
        argv = e.get("arguments") or shlex.split(e["command"])
        f = os.path.normpath(os.path.join(e["directory"], e["file"]))
        db[f] = (argv, e["directory"], build_root)
    return db


def classify(entry, src_file):
    argv, cwd, build_root = entry
    defines, includes, external, flags = set(), set(), set(), set()

    def norm(p):
        p = os.path.normpath(os.path.join(cwd, p))
        if p == build_root or p.startswith(build_root + "/"):
            return "<build>" + p[len(build_root):]
        if p == TOP or p.startswith(TOP + "/"):
            return "<src>" + p[len(TOP):]
        return None

    it = iter(argv[1:])
    for a in it:
        if a in ("-c", "--"):
            continue
        if a == "-o":
            next(it, None)
            continue
        if a.startswith("-o"):
            continue
        if os.path.normpath(os.path.join(cwd, a)) == src_file:
            continue
        if a.startswith("-D"):
            d = a[2:] or next(it, "")
            name = d.split("=", 1)[0]
            if not name.endswith("_EXPORTS") and name not in ignored_defines:
                defines.add(d)
            continue
        inc = None
        for opt in ("-isystem", "-iquote", "-I"):
            if a.startswith(opt):
                inc = a[len(opt):] or next(it, "")
                break
        if inc is not None:
            n = norm(inc)
            (includes if n else external).add(n or inc)
            continue
        # Toolchain plumbing CMake adds and waf leaves to the compiler driver.
        if a in ("-isysroot", "-arch", "-x", "-target"):
            next(it, None)
            continue
        if a.startswith("-mmacosx-version-min="):
            continue
        if a.startswith("-std="):
            flags.add(a.replace("gnu", "c"))
            continue
        flags.add(a)
    return {"defines": defines, "includes": includes, "external": external, "flags": flags}


waf = load(positional[0])
cmake = load(positional[1])

groups = defaultdict(lambda: defaultdict(list))
compared = 0
for f, w in waf.items():
    if f not in cmake:
        continue
    compared += 1
    W, C = classify(w, f), classify(cmake[f], f)
    kinds = ["defines", "includes", "flags"] + (["external"] if show_external else [])
    rel = os.path.relpath(f, TOP)
    for kind in kinds:
        for side, items in (("waf only", W[kind] - C[kind]), ("cmake only", C[kind] - W[kind])):
            for item in items:
                groups[os.path.dirname(rel)][f"{kind} {side}: {item}"].append(rel)

only_waf = sorted(os.path.relpath(f, TOP) for f in waf if f not in cmake)
only_cmake = sorted(os.path.relpath(f, TOP) for f in cmake if f not in waf)

print(f"compared {compared} files; {len(only_waf)} compiled only by waf, {len(only_cmake)} only by CMake")
for key in sorted(groups):
    print(f"\n{key}/")
    for k in sorted(groups[key]):
        files = groups[key][k]
        print(f"  {k}  ({len(files)} file{'' if len(files) == 1 else 's'})")
        if show_files:
            for f in files:
                print(f"      {f}")
if only_waf:
    print("\nonly waf compiles:\n  " + "\n  ".join(only_waf))
if only_cmake:
    print("\nonly CMake compiles:\n  " + "\n  ".join(only_cmake))

sys.exit(1 if groups or only_waf or only_cmake else 0)
