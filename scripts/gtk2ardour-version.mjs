#!/usr/bin/env node
// gtk2ardour-version.h for the CMake build, as gtk2_ardour/wscript's
// configure() writes it: VERSIONSTRING and CODENAME, in waf's
// write_config_header() format. Only rewritten when the content changes.
//
//   node scripts/gtk2ardour-version.mjs <version> <major> <minor> <out>
//
// enoify() is a 1:1 port of the wscript's codename table (Brian Eno albums by
// release); keep the two in sync.

import { existsSync, readFileSync, writeFileSync } from "node:fs";

const albums = {
    3: () => "E-No",
    4: (m) => ["No Pussyfooting", "Here Come the Warm Jets", "Taking Tiger Mountain",
        "Lady June's Linguistic Leprosy", "Discreet Music", "Another Green World",
        "Evening Star", "Cluster and Eno"][m],
    5: (m) => ["Before and After Science", "After the Heat", "Music for Airports",
        "Music for Films", "In a Land of Clear Colours", "The Plateaux of Mirror",
        "Possible Musics", "My Life in the Bush of Ghosts", "Music for Airplay", "On Land",
        "Atmospheres and Soundtracks", "More Music for Films", "Working Backwards"][m],
    6: (m) => ["The Pearl", "Begegnungen", "Thursday Afternoon", "Hybrid", "Old Land",
        "Old Land", "Desert Island Selection", "Desert Island Selection"][m] ?? "After Bach",
    7: (m) => ["More Blank Than Frank", "Music for Films III", "Wrong Way Up", "Nerve Net",
        "The Shutov Assembly", "Neroli"][m],
    8: (m) => m >= 7 ? "Sonora Portraits" : ["Spinner", "The Drop", "Tracks and Traces",
        "Music for White Cube", "Music for the Marble Palace", "I Dormienti", "Kite Stories"][m],
    9: (m) => ["Music for Civic Recovery Centre", "Music for Onmyo-Ji", "Compact Forest Proposal",
        "Drawn from Life", "Drawn from Life", "Drawn from Life",
        "Bell Studies for the Clock of the Long Now", "Bell Studies for the Clock of the Long Now",
        "The Equatorial Stars", "Another Day on Earth", "77 Million Paintings", "Beyond Even",
        "Making Space "][m],
};

function enoify(major, minor) {
    const name = albums[major]?.(minor);
    return name === undefined ? '\\"\\"' : `\\n\\"${name}\\"`;
}

const [version, major, minor, out] = process.argv.slice(2);
const guard = "W_GTK2ARDOUR_VERSION_H_WAF";
const text =
    "/* WARNING! All changes made to this file will be lost! */\n\n" +
    `#ifndef ${guard}\n#define ${guard}\n\n` +
    `#define VERSIONSTRING "${version}"\n` +
    `#define CODENAME "${enoify(Number(major), Number(minor))}"\n` +
    `\n#endif /* ${guard} */\n`;

if (!existsSync(out) || readFileSync(out, "utf8") !== text) {
    writeFileSync(out, text);
}
