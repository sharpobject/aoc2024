const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part12() !struct{?i128, ?i128} {
    var lines = u.trimSplit(input, '\n');
    var s1: i64 = 0;
    var s2: i64 = 0;
    u.use3(&s1, &s2, &lines);
    lines = u.pad(lines, '.', 1);

    var x: usize = 0;
    var y: usize = 0;
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == 'S') {
                x = i;
                y = j;
            }
        }
    }

    var right: [256]bool = [_]bool{false} ** 256;
    var left: [256]bool = [_]bool{false} ** 256;
    var up: [256]bool = [_]bool{false} ** 256;
    var down: [256]bool = [_]bool{false} ** 256;
    right['S'] = true;
    right['-'] = true;
    right['L'] = true;
    right['F'] = true;
    up['S'] = true;
    up['|'] = true;
    up['L'] = true;
    up['J'] = true;
    left['S'] = true;
    left['-'] = true;
    left['J'] = true;
    left['7'] = true;
    down['S'] = true;
    down['|'] = true;
    down['F'] = true;
    down['7'] = true;

    const visited = u.mapc(lines, false);
    const doodle = u.mapc(lines, @as(u8, '.'));
    var map2 = u.alloc([]u8, lines.len * 2);
    for (map2) |*line| {
        line.* = u.alloc(u8, lines[0].len * 2);
        @memset(line.*, '.');
    }
    var q = u.Queue(struct{usize, usize, usize}){};
    q.push(.{ x, y, 0});
    var maxd: usize = 0;
    while (q.len > 0) {
        x, y, const d= q.pop();
        if (visited[x][y]) continue;
        doodle[x][y] = '0' + @as(u8, @intCast(d % 10));
        maxd = @max(maxd, d);
        visited[x][y] = true;
        const c = lines[x][y];
        const nc = lines[x-1][y];
        const ec = lines[x][y+1];
        const sc = lines[x+1][y];
        const wc = lines[x][y-1];
        map2[x*2][y*2] = c;
        if (right[c] and left[ec]) {
            map2[x*2][y*2+1] = '-';
            q.push(.{ x, y+1, d+1 });
        }
        if (left[c] and right[wc]) {
            map2[x*2][y*2-1] = '-';
            q.push(.{ x, y-1, d+1 });
        }
        if (up[c] and down[nc]) {
            map2[x*2-1][y*2] = '|';
            q.push(.{ x-1, y, d+1 });
        }
        if (down[c] and up[sc]) {
            map2[x*2+1][y*2] = '|';
            q.push(.{ x+1, y, d+1 });
        }
    }

    map2 = u.pad(map2, '#', 1);


    for (map2) |line| {
        std.debug.print("{s}\n", .{line});
    }


    const visited2 = u.mapc(map2, false);
    q.push(.{ 1, 1, 0 });
    const dxs: [4]u64 = @bitCast([4]i64{ 1, -1, 0, 0 });
    const dys: [4]u64 = @bitCast([4]i64{ 0, 0, 1, -1 });
    while (q.len > 0) {
        x, y, const d = q.pop();
        if (visited2[x][y]) continue;
        _ = d;
        if (map2[x][y] == '.') {
            visited2[x][y] = true;
            for (dxs, dys) |dx, dy| {
                const nx = x +% dx;
                const ny = y +% dy;
                q.push(.{ nx, ny, 0 });
            }
        }
    }
    for (0..lines.len) |i| {
        for (0..lines[0].len) |j| {
            if (!visited[i][j] and !visited2[i*2+1][j*2+1]) {
                map2[i*2+1][j*2+1] = 'A';
                s2 += 1;
            }
        }
    }

    for (doodle) |line| {
        std.debug.print("{s}\n", .{line});
    }


    for (map2) |line| {
        std.debug.print("{s}\n", .{line});
    }


    return .{ maxd, s2 };
}
