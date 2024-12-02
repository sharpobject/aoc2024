const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    const lr = lines[0];
    lines = lines[1..];
    const l: []usize = u.alloc(usize, 36*36*36);
    const r: []usize = u.alloc(usize, 36*36*36);
    for (lines) |line| {
        const stuff = u.trimSplit(u.filterOut(line, "(),="), ' ');
        const a = try std.fmt.parseInt(usize, stuff[0], 36);
        const b = try std.fmt.parseInt(usize, stuff[1], 36);
        const c = try std.fmt.parseInt(usize, stuff[2], 36);
        l[a] = b;
        r[a] = c;
    }
    var state: usize = try std.fmt.parseInt(usize, "AAA", 36);
    const finish = try std.fmt.parseInt(usize, "ZZZ", 36);
    var i: usize = 0;
    while (state != finish) {
        if (lr[i] == 'L') {
            state = l[state];
        } else {
            state = r[state];
        }
        i = (i + 1) % lr.len;
        sum += 1;
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i128 = 0;
    u.use(&sum, &lines);
    const lr = lines[0];
    lines = lines[1..];
    const l: []usize = u.alloc(usize, 36*36*36);
    const r: []usize = u.alloc(usize, 36*36*36);
    var lrmap: [256][]usize = undefined;
    lrmap['L'] = l;
    lrmap['R'] = r;
    var states: []usize = u.alloc(usize, lines.len);
    var n_states: usize = 0;
    for (lines) |line| {
        const stuff = u.trimSplit(u.filterOut(line, "(),="), ' ');
        const a = try std.fmt.parseInt(usize, stuff[0], 36);
        const b = try std.fmt.parseInt(usize, stuff[1], 36);
        const c = try std.fmt.parseInt(usize, stuff[2], 36);
        l[a] = b;
        r[a] = c;
        if (a % 36 == 10) {
            states[n_states] = a;
            n_states += 1;
        }
    }
    states = states[0..n_states];
    const ends: []i128 = u.alloc(i128, states.len);
    for (ends) |*xd| {
        xd.* = 0;
    }
    var n_ends: usize = 0;
    var i: usize = 0;
    while (n_ends < states.len) {
        sum += 1;
        for (states, 0..) |*state, sidx| {
            state.* = lrmap[lr[i]][state.*];
            if (state.* % 36 == 35 and ends[sidx] == 0) {
                ends[sidx] = sum;
                n_ends += 1;
            }
        }
        i = (i + 1) % lr.len;
    }
    sum = 1;
    for (ends) |end| {
        sum = u.lcm(sum, end);
    }
    return sum;
}
