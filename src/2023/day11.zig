const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

fn expand(xs: []isize, dx: isize) void {
    var x = u.max(xs);
    while (x > 0) {
        x -= 1;
        var xp = true;
        for (xs) |gx| {
            if (gx == x) {
                xp = false;
                break;
            }
        }
        if (xp) {
            for (xs) |*gx| {
                if (gx.* > x) {
                    gx.* += dx;
                }
            }
        }
    }
}

pub fn part12() !struct{?i128, ?i128} {
    var lines = u.trimSplit(input, '\n');
    var s1: i64 = 0;
    var s2: i64 = 0;
    u.use3(&s1, &s2, &lines);
    var galxl = std.ArrayList(isize).init(gpa);
    var galyl = std.ArrayList(isize).init(gpa);
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == '#') {
                try galxl.append(@intCast(i));
                try galyl.append(@intCast(j));
            }
        }
    }
    expand(galxl.items, 1);
    expand(galyl.items, 1);
    for (0..galxl.items.len) |i| {
        for (i+1..galxl.items.len) |j| {
            const x1 = galxl.items[i];
            const y1 = galyl.items[i];
            const x2 = galxl.items[j];
            const y2 = galyl.items[j];
            s1 += @intCast(@abs(x2 - x1) + @abs(y2 - y1));
        }
    }
    expand(galxl.items, 499999);
    expand(galyl.items, 499999);
    
    for (0..galxl.items.len) |i| {
        for (i+1..galxl.items.len) |j| {
            const x1 = galxl.items[i];
            const y1 = galyl.items[i];
            const x2 = galxl.items[j];
            const y2 = galyl.items[j];
            s2 += @intCast(@abs(x2 - x1) + @abs(y2 - y1));
        }
    }




    return .{ s1, s2 };
}
