#!/usr/bin/env node
// Compare the per-file compile flags of a waf build and a CMake build.
//
//   ./waf configure --compile-database ... && ./waf
//   cmake -S . -B build-cmake && cmake --build build-cmake
//   node scripts/compare-compile-commands.mjs build/compile_commands.json \
//        build-cmake/compile_commands.json [--external] [--files]
//
// For every source file both builds compile, it diffs the -D defines, the
// in-tree include directories (source and build tree, normalised so the two
// build directories compare equal) and the remaining flags, then groups the
// differences by source directory. --external also diffs include dirs outside
// the tree (pkg-config paths); --files lists each differing file.
// Exit status is 1 when anything differs, so it can gate CI.

import { readFileSync } from "node:fs";
import { dirname, isAbsolute, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const top = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const showExternal = args.includes("--external");
const showFiles = args.includes("--files");
// --ignore-define=NAME (repeatable): drop a define on both sides, e.g. one the
// waf build only has because it was passed in CFLAGS.
const ignoredDefines = args.filter((a) => a.startsWith("--ignore-define=")).map((a) => a.slice(16));

if (positional.length !== 2) {
    console.error("usage: compare-compile-commands.mjs <waf compile_commands.json> <cmake compile_commands.json> [--external] [--files]");
    process.exit(2);
}

// POSIX-shell word splitting, enough for compile_commands "command" strings:
// CMake writes -DPACKAGE=\"x\", waf writes "arguments" arrays.
function splitCommand(cmd) {
    const out = [];
    let cur = "";
    let inWord = false;
    let quote = null;
    for (let i = 0; i < cmd.length; i++) {
        const ch = cmd[i];
        if (quote === "'") {
            if (ch === "'") quote = null; else cur += ch;
        } else if (quote === '"') {
            if (ch === "\\" && i + 1 < cmd.length) cur += cmd[++i];
            else if (ch === '"') quote = null;
            else cur += ch;
        } else if (ch === "\\" && i + 1 < cmd.length) {
            cur += cmd[++i]; inWord = true;
        } else if (ch === "'" || ch === '"') {
            quote = ch; inWord = true;
        } else if (/\s/.test(ch)) {
            if (inWord) out.push(cur);
            cur = ""; inWord = false;
        } else {
            cur += ch; inWord = true;
        }
    }
    if (inWord) out.push(cur);
    return out;
}

function load(path) {
    const db = JSON.parse(readFileSync(path, "utf8"));
    const buildRoot = resolve(dirname(path));
    const map = new Map();
    for (const e of db) {
        const argv = e.arguments ?? splitCommand(e.command);
        const file = normalize(isAbsolute(e.file) ? e.file : join(e.directory, e.file));
        map.set(file, { argv, dir: e.directory, buildRoot });
    }
    return map;
}

function classify({ argv, dir, buildRoot }, file) {
    const defines = new Set();
    const includes = new Set();
    const external = new Set();
    const flags = new Set();

    const norm = (p) => {
        const abs = normalize(isAbsolute(p) ? p : join(dir, p)).replace(/\/$/, "");
        if (abs === buildRoot || abs.startsWith(buildRoot + "/")) return "<build>" + abs.slice(buildRoot.length);
        if (abs === top || abs.startsWith(top + "/")) return "<src>" + abs.slice(top.length);
        return null;
    };

    for (let i = 1; i < argv.length; i++) {
        const a = argv[i];
        const next = () => argv[++i];
        if (a === "-c" || a === "--") continue;
        if (a === "-o") { i++; continue; }
        if (a.startsWith("-o")) continue;
        if (normalize(isAbsolute(a) ? a : join(dir, a)) === file) continue;
        if (a === "-D" || a.startsWith("-D")) {
            const d = a === "-D" ? next() : a.slice(2);
            const name = d.split("=")[0];
            // CMake defines <target>_EXPORTS for every shared library on its own.
            if (!name.endsWith("_EXPORTS") && !ignoredDefines.includes(name)) defines.add(d);
            continue;
        }
        let inc = null;
        if (a === "-I" || a === "-isystem" || a === "-iquote") inc = next();
        else if (a.startsWith("-I")) inc = a.slice(2);
        else if (a.startsWith("-isystem")) inc = a.slice(8);
        if (inc !== null) {
            const n = norm(inc);
            if (n) includes.add(n);
            else external.add(inc);
            continue;
        }
        // Toolchain plumbing CMake adds and waf leaves to the compiler driver.
        if (a === "-isysroot" || a === "-arch" || a === "-x" || a === "-target") { i++; continue; }
        if (a.startsWith("-mmacosx-version-min=")) continue;
        if (a.startsWith("-std=")) { flags.add(a.replace("gnu", "c")); continue; }
        flags.add(a);
    }
    return { defines, includes, external, flags };
}

const diff = (a, b) => [[...a].filter((x) => !b.has(x)), [...b].filter((x) => !a.has(x))];

const waf = load(positional[0]);
const cmake = load(positional[1]);

const groups = new Map();
let compared = 0;
for (const [file, w] of waf) {
    const c = cmake.get(file);
    if (!c) continue;
    compared++;
    const W = classify(w, file);
    const C = classify(c, file);
    const kinds = { defines: diff(W.defines, C.defines), includes: diff(W.includes, C.includes), flags: diff(W.flags, C.flags) };
    if (showExternal) kinds.external = diff(W.external, C.external);
    const key = dirname(file.slice(top.length + 1));
    for (const [kind, [onlyWaf, onlyCmake]] of Object.entries(kinds)) {
        for (const [side, list] of [["waf only", onlyWaf], ["cmake only", onlyCmake]]) {
            for (const item of list) {
                if (!groups.has(key)) groups.set(key, new Map());
                const g = groups.get(key);
                const k = `${kind} ${side}: ${item}`;
                if (!g.has(k)) g.set(k, []);
                g.get(k).push(file.slice(top.length + 1));
            }
        }
    }
}

const onlyWaf = [...waf.keys()].filter((f) => !cmake.has(f)).map((f) => f.slice(top.length + 1));
const onlyCmake = [...cmake.keys()].filter((f) => !waf.has(f)).map((f) => f.slice(top.length + 1));

console.log(`compared ${compared} files; ${onlyWaf.length} compiled only by waf, ${onlyCmake.length} only by CMake`);
for (const [key, g] of [...groups].sort()) {
    console.log(`\n${key}/`);
    for (const [k, files] of [...g].sort()) {
        console.log(`  ${k}  (${files.length} file${files.length === 1 ? "" : "s"})`);
        if (showFiles) for (const f of files) console.log(`      ${f}`);
    }
}
if (onlyWaf.length) console.log(`\nonly waf compiles:\n  ${onlyWaf.sort().join("\n  ")}`);
if (onlyCmake.length) console.log(`\nonly CMake compiles:\n  ${onlyCmake.sort().join("\n  ")}`);

process.exit(groups.size || onlyWaf.length || onlyCmake.length ? 1 : 0);
