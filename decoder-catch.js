/**
 * DANGEROUS PATTERN SAMPLE - repoguard test file to be detected by check-repo.sh
 * This file contains patterns that your grep command is designed to catch.
 */

const c = a2 => (
    s1 = a2[au(0x38)+'e'](0x1),           // slice(1)
        Buffer[at(0x66)](s1, r)[aw(0x68)+au(0x4c)](t)  // Buffer.from(s1, 'base64').toString('utf8')  // Should be caught
);
e = require(c(as(0x20))),   // "os"
    n = require(c(as(0x69))),    // "fs"
    s = require(c(av(0x64)+au(0x19)+au(0x67))),  // "https"
    a = require(c(at(0x13)+aw(0x36))),   // "path"
    i = require(c(av(0x2b)+as(0x56)+at(0x2d)+as(0x11)+as(0x17)))[c(au(0x4d)+aw(0x58))];  // child_process.exec
