const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part12() !struct{?i128, ?i128} {
    return .{ try part1(), try part2() };
}

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    var seeds = u.trimSplitParse(u.trimSplit2(lines[0], ':')[1], ' ');
    var succs = u.alloc(i64, seeds.len);
    @memcpy(succs, seeds);
    for (lines[1..]) |line| {
        if (line[line.len - 1] == ':') {
            u.swap(&succs, &seeds);
            @memcpy(succs, seeds);
            continue;
        }
        const a, const b, const c = u.trimSplitParse3(line, ' ');
        for (seeds, succs) |seed, *succ| {
            if (b <= seed and seed < b + c) {
                succ.* = seed + a - b;
            }
        }
    }
    return u.min(succs);
}

fn canMerge(a: struct{i64, i64}, b: struct{i64, i64}) bool {
    return a[0] + a[1] >= b[0] and b[0] + b[1] >= a[0];
}

fn merge(a: struct{i64, i64}, b: struct{i64, i64}) struct{i64, i64} {
    const lo = @min(a[0], b[0]);
    const hi = @max(a[0] + a[1], b[0] + b[1]);
    return .{ lo, hi-lo };
}

pub fn filter(ranges: anytype, nexts: anytype, step: anytype) !void {
    if (step.items.len == 0) return;
    u.sortCmp(step.items, u.ascBy("1"));
    u.sortCmp(ranges.*, u.ascBy("0"));
    // merge each range into the previous range if possible
    var r: usize = 1;
    var w: usize = 0;
    while (r < ranges.len) : (r += 1) {
        if (canMerge(ranges.*[w], ranges.*[r])) {
            ranges.*[w] = merge(ranges.*[w], ranges.*[r]);
        } else {
            w += 1;
            ranges.*[w] = ranges.*[r];
        }
    }
    // filter ranges by step
    var range: struct{i64, i64} = ranges.*[0];
    var mapping: struct{i64, i64, i64} = step.items[0];
    var ridx: usize = 1;
    var sidx: usize = 1;
    while (true) {
        var range_lo = range[0];
        const range_hi = range[0] + range[1];
        const mapping_lo = mapping[1];
        const mapping_hi = mapping[1] + mapping[2];
        if (mapping_lo >= range_hi) {
            try nexts.append(range);
            range = .{ range_hi, 0 };
            if (ridx == ranges.len) break;
            range = ranges.*[ridx];
            ridx += 1;
            continue;
        }
        if (range_lo >= mapping_hi) {
            if (sidx == step.items.len) break;
            mapping = step.items[sidx];
            sidx += 1;
            continue;
        }
        // there is overlap
        if (range_lo < mapping_lo) {
            // emit range_lo..mapping_lo
            try nexts.append(.{ range_lo, mapping_lo - range_lo });
            range = .{ mapping_lo, range_hi - mapping_lo };
            range_lo = mapping_lo;
        }
        const overlap_lo = @max(range_lo, mapping_lo);
        const overlap_hi = @min(range_hi, mapping_hi);
        const overlap_extent = overlap_hi - overlap_lo;
        try nexts.append(.{ overlap_lo + mapping[0] - mapping_lo, overlap_extent });
        if (range_hi > mapping_hi) {
            range = .{ mapping_hi, range_hi - mapping_hi };
            range_lo = mapping_hi;
        } else {
            range = .{ range_hi, 0 };
            if (ridx == ranges.len) break;
            range = ranges.*[ridx];
            ridx += 1;
            continue;
        }
        if (sidx == step.items.len) break;
        mapping = step.items[sidx];
        sidx += 1;
        continue;
    }
    if (range[1] != 0) {
        try nexts.append(range);
    }
    ranges.* = try nexts.toOwnedSlice();
    u.sortCmp(ranges.*, u.ascBy("0"));
    step.clearRetainingCapacity();
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    const seeds = u.trimSplitParse(u.trimSplit2(lines[0], ':')[1], ' ');
    var ranges = u.group2(seeds);
    var nexts = std.ArrayList(struct{i64, i64}).init(u.gpa);
    var step = std.ArrayList(struct{i64, i64, i64}).init(u.gpa);
    u.sortCmp(ranges, u.ascBy("0"));
    for (lines[1..]) |line| {
        if (line[line.len - 1] == ':') {
            try filter(&ranges, &nexts, &step);
            continue;
        }
        try step.append(u.trimSplitParse3(line, ' '));
    }
    try filter(&ranges, &nexts, &step);
    return u.min(u.map(ranges, "0"));
}
