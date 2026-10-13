#!/usr/bin/env node
// Ardour's version, derived from git the way the root wscript's set_version()
// and create_stored_revision() do it, for the CMake build.
//
//   node scripts/ardour-version.mjs --json
//       Print {"major","minor","micro","version","revision","date"} for
//       CMake to read at configure time.
//
//   node scripts/ardour-version.mjs --revision-cc <out>
//       Write libs/ardour/revision.cc's content to <out> (only when it
//       changed, so an unchanged HEAD does not relink libardour). waf rewrites
//       revision.cc in the source tree on every build; CMake runs this on
//       every build instead and keeps the result in the build tree.
//
// Without a .git (a release tarball) both read the revision.cc the tarball was
// rolled with, as fetch_tarball_revision_date() does.

import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const top = join(dirname(fileURLToPath(import.meta.url)), "..");
const storedRevision = join(top, "libs", "ardour", "revision.cc");

function git(...args) {
    return execFileSync("git", args, { cwd: top, encoding: "utf8" }).split("\n")[0];
}

// The wscript round-trips through ASCII to drop anything non-encodable.
const sanitize = (s) => s.replace(/[^\x00-\x7f]/g, "");

function fetchRevisionDate() {
    if (existsSync(join(top, ".git"))) {
        const rev = git("describe", "HEAD").replace(/^[A-Za-z0-9]*\+/, "");
        const date = git("log", "-1", "--pretty=format:%ci", "HEAD").split(/\s+/)[0];
        return { rev, date, fromGit: true };
    }
    if (!existsSync(storedRevision)) {
        console.error("This tarball was not created correctly - it is missing libs/ardour/revision.cc");
        process.exit(1);
    }
    // fetch_tarball_revision_date(): tokens 7 and 12 of the second line.
    const tokens = readFileSync(storedRevision, "utf8").split("\n")[1].trim().split(" ");
    const strip = (t) => t.replace(/[";]/g, "");
    return { rev: strip(tokens[7]), date: strip(tokens[12]), fromGit: false };
}

function parseVersion(rev) {
    // MAJOR.MINOR[-rcX]-rev-commit, or MAJOR.MINOR[-rcX] right at a release.
    const [major, rest] = sanitize(rev).split(/\.(.*)/s);
    const dash = rest.indexOf("-");
    const minor = dash < 0 ? rest : rest.slice(0, dash);
    let micro = "0";
    if (dash >= 0) {
        const tail = rest.slice(dash + 1);
        const last = tail.lastIndexOf("-");
        micro = (last < 0 ? tail : tail.slice(0, last)).replaceAll("-", ".");
    }
    return { major, minor, micro };
}

const args = process.argv.slice(2);
const { rev, date, fromGit } = fetchRevisionDate();

if (args[0] === "--json") {
    const { major, minor, micro } = parseVersion(rev);
    process.stdout.write(JSON.stringify({
        major, minor, micro,
        version: `${major}.${minor}.${micro}`,
        revision: rev,
        date: sanitize(date),
    }));
} else if (args[0] === "--revision-cc" && args[1]) {
    const out = args[1];
    // Keep this format: fetch_tarball_revision_date() parses it back.
    const text = fromGit
        ? '#include "ardour/revision.h"\n' +
          `namespace ARDOUR { const char* revision = "${rev}"; const char* date = "${date}"; }\n`
        : readFileSync(storedRevision, "utf8");
    if (!existsSync(out) || readFileSync(out, "utf8") !== text) {
        writeFileSync(out, text);
    }
} else {
    console.error("usage: ardour-version.mjs --json | --revision-cc <out>");
    process.exit(2);
}
