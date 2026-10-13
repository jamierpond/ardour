#!/usr/bin/env python3
"""Write gtk2ardour-version.h for the CMake build.

    gen-gtk2ardour-version.py <gtk2_ardour/wscript> <version> <major> <minor> <out>

gtk2_ardour/wscript's configure() writes this header with two defines,
VERSIONSTRING and CODENAME, where CODENAME comes from the wscript's enoify()
table (a Brian Eno album per release). Rather than keep a second copy of that
table, this pulls enoify() out of the wscript itself (it is plain Python with
no waf dependencies) so the two builds can never disagree on a codename. The output matches waf's
write_config_header() byte for byte, and is only rewritten when it changes.
"""
import ast
import os
import sys

wscript, version, major, minor, out = sys.argv[1:6]

tree = ast.parse(open(wscript).read(), wscript)
enoify = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "enoify")
scope = {}
exec(compile(ast.Module(body=[enoify], type_ignores=[]), wscript, "exec"), scope)
codename = scope["enoify"](int(major), int(minor))

guard = "W_GTK2ARDOUR_VERSION_H_WAF"
text = (
    "/* WARNING! All changes made to this file will be lost! */\n\n"
    f"#ifndef {guard}\n#define {guard}\n\n"
    f'#define VERSIONSTRING "{version}"\n'
    f'#define CODENAME "{codename}"\n'
    f"\n#endif /* {guard} */\n"
)

if not os.path.exists(out) or open(out).read() != text:
    with open(out, "w") as f:
        f.write(text)
