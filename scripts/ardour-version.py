#!/usr/bin/env python3
"""Ardour's version, derived from git the way the root wscript's set_version()
and create_stored_revision() do it, for the CMake build.

    ardour-version.py --json
        Print {"major","minor","micro","version","revision","date"} for CMake
        to read at configure time.

    ardour-version.py --revision-cc <out>
        Write libs/ardour/revision.cc's content to <out>, only when it changed
        (so an unchanged HEAD does not relink libardour). waf rewrites
        revision.cc in the source tree on every build; CMake runs this on every
        build instead and keeps the result in the build tree.

Without a .git (a release tarball) both read the revision.cc the tarball was
rolled with, as fetch_tarball_revision_date() does.
"""
import json
import os
import re
import subprocess
import sys

TOP = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
STORED_REVISION = os.path.join(TOP, "libs", "ardour", "revision.cc")


def sanitize(s):
    # round-trip through ASCII, as the wscript does
    return s.encode("ascii", "ignore").decode("utf-8")


def git(*args):
    out = subprocess.run(["git", *args], cwd=TOP, check=True, capture_output=True, text=True).stdout
    return out.splitlines()[0]


def fetch_revision_date():
    if os.path.exists(os.path.join(TOP, ".git")):
        rev = re.sub(r"^[A-Za-z0-9]*\+", "", git("describe", "HEAD"))
        date = git("log", "-1", "--pretty=format:%ci", "HEAD").split(None, 2)[0]
        return rev, date, True
    if not os.path.exists(STORED_REVISION):
        print("This tarball was not created correctly - it is missing libs/ardour/revision.cc")
        sys.exit(1)
    # fetch_tarball_revision_date(): tokens 7 and 12 of the second line.
    with open(STORED_REVISION) as f:
        tokens = f.readlines()[1].strip().split(" ")
    strip = lambda t: t.replace('"', "").replace(";", "")
    return strip(tokens[7]), strip(tokens[12]), False


def parse_version(rev):
    # set_version(): MAJOR.MINOR[-rcX]-rev-commit, or MAJOR.MINOR[-rcX]
    parts = sanitize(rev).split(".", 1)
    major = parts[0]
    other = parts[1].split("-", 1)
    minor = other[0]
    micro = other[1].rsplit("-", 1)[0].replace("-", ".") if len(other) > 1 else "0"
    return major, minor, micro


def main():
    rev, date, from_git = fetch_revision_date()

    if sys.argv[1:2] == ["--json"]:
        major, minor, micro = parse_version(rev)
        json.dump({
            "major": major, "minor": minor, "micro": micro,
            "version": f"{major}.{minor}.{micro}",
            "revision": rev,
            "date": sanitize(date),
        }, sys.stdout)
    elif sys.argv[1:2] == ["--revision-cc"] and len(sys.argv) > 2:
        out = sys.argv[2]
        if from_git:
            # Keep this format: fetch_tarball_revision_date() parses it back.
            text = ('#include "ardour/revision.h"\n'
                    'namespace ARDOUR { const char* revision = "%s"; '
                    'const char* date = "%s"; }\n') % (rev, date)
        else:
            with open(STORED_REVISION) as f:
                text = f.read()
        if not os.path.exists(out) or open(out).read() != text:
            with open(out, "w") as f:
                f.write(text)
    else:
        print("usage: ardour-version.py --json | --revision-cc <out>", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
