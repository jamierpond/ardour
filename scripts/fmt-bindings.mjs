#!/usr/bin/env node
// ardour.keys for the CMake build: the --accelmap 1 mode of
// tools/fmt-bindings.py (the only mode the wscript runs), ported 1:1 so the
// build needs no Python. The cheat-sheet/HTML/merge modes stay in the Python
// tool.
//
//   node scripts/fmt-bindings.mjs <ardour.keys.in> > ardour.keys

import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const input = process.argv[2];
const out = [];
const print = (s) => out.push(s + "\n");

const groupNames = {};
const groupOwners = {};
const ownerBindings = {};
let inGroupDef = false;
let groupKey = "";
let groupName = "";

// re.split(pattern, s, maxsplit=n)
function splitMax(s, re, n) {
    const parts = [];
    let rest = s;
    while (parts.length < n) {
        const m = re.exec(rest);
        if (!m) break;
        parts.push(rest.slice(0, m.index));
        rest = rest.slice(m.index + m[0].length);
    }
    parts.push(rest);
    return parts;
}

print('<?xml version="1.0" encoding="UTF-8"?>');
const bindingsName = basename(input).replace(/\.bindings\.in$/, "");

for (let line of readFileSync(input, "utf8").split(/(?<=\n)/)) {
    if (line.startsWith(";")) continue;
    if (line.startsWith("$")) continue;

    if (line.startsWith("%")) {
        if (inGroupDef) groupNames[groupKey] = groupName;
        const [key, owner, name] = splitMax(line.slice(1).replace(/\n$/, ""), /\s+/, 2);
        groupKey = key;
        groupName = name;
        ownerBindings[owner] ??= [];
        groupOwners[groupKey] = owner;
        inGroupDef = true;
        continue;
    }

    if (inGroupDef) {
        if (line.startsWith("@")) {
            groupNames[groupKey] = groupName;
            inGroupDef = false;
        } else {
            continue;
        }
    }

    if (line.startsWith("@")) {
        const [key, action, rawBinding] = splitMax(line.slice(1).replace(/\n$/, ""), /\|/, 3);
        const gkey = key.replace(/^-/, "");
        const owner = groupOwners[gkey];
        const binding = rawBinding.replace(/^\s+|\s+$/g, "");

        // "+" keys are forced into the cheat sheet and never into the accelmap.
        if (!key.startsWith("+") && owner !== undefined && owner in ownerBindings) {
            const b = binding.replace(/<@/g, "").replace(/@>/g, "")
                .replace(/PRIMARY/g, "Primary-").replace(/SECONDARY/g, "Secondary-")
                .replace(/TERTIARY/g, "Tertiary-").replace(/LEVEL4/g, "Level4-");
            const g = (groupNames[gkey] ?? "").replace(/\\&/g, "&amp;");
            ownerBindings[owner].push([action, b, g]);
        }
    }
}

print(`<BindingSet name="${bindingsName}">`);
for (const owner of Object.keys(ownerBindings).sort()) {
    print(` <Bindings name="${owner}">\n  <Press>`);
    for (const [action, key, group] of ownerBindings[owner]) {
        print(`   <Binding key="${key}" action="${action}" group="${group}"/>`);
    }
    print("  </Press>\n </Bindings>");
}

// "Merge in the 'fixed' bindings that are not defined by the argument given
// to this program."
for (const file of ["mixer.bindings", "step_editing.bindings", "monitor.bindings", "processor_box.bindings",
    "trigger.bindings", "regionfx_box.bindings", "automation.bindings"]) {
    out.push(readFileSync(join(dirname(input), file), "utf8"));
}
print("</BindingSet>");

process.stdout.write(out.join(""));
