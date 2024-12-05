const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

var lts: [10000]i64 = [_]i64{0} ** 10000;
var gts: [10000]i64 = [_]i64{0} ** 10000;

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    var nlts: usize = 0;
    for (lines) |line| {
        const xd = u.trimSplit(line, '|');
        if (xd.len == 2) {
            const ltx, const gtx = u.trimSplitParse2(line, '|');
            lts[nlts] = ltx;
            gts[nlts] = gtx;
            nlts += 1;
        } else {
            const xs = u.trimSplitParse(line, ',');
            var ok = true;
            for (xs, 0..) |x, i| {
                for (xs[i+1..]) |y| {
                    for (lts[0..nlts], gts[0..nlts]) |lt, gt| {
                        if (x == gt and y == lt and ok) {
                            ok = false;
                        }
                    }
                }
            }
            if (ok) {
                sum += xs[(xs.len - 1)/2];
            }
        }
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    var nlts: usize = 0;
    for (lines) |line| {
        const xd = u.trimSplit(line, '|');
        if (xd.len == 2) {
            const ltx, const gtx = u.trimSplitParse2(line, '|');
            lts[nlts] = ltx;
            gts[nlts] = gtx;
            nlts += 1;
        } else {
            const xs = u.trimSplitParse(line, ',');
            var ok = true;
            for (xs, 0..) |*x, i| {
                for (xs[i+1..]) |*y| {
                    var changed = true;
                    while (changed) {
                        changed = false;
                        for (lts[0..nlts], gts[0..nlts]) |lt, gt| {
                            if (x.* == gt and y.* == lt) {
                                x.* = lt;
                                y.* = gt;
                                changed = true;
                                ok = false;
                            }
                        }
                    }
                }
            }
            if (!ok) {
                sum += xs[(xs.len - 1)/2];
            }
        }
    }
    return sum;
}
