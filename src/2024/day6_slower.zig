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
    const dxs: [4]u64 = @bitCast([4]i64{ -1, 0, 1, 0 });
    const dys: [4]u64 = @bitCast([4]i64{ 0, 1, 0, -1 });
    var facing: usize = 0;
    var x: u64 = 0;
    var y: u64 = 0;
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == '^') {
                x = i;
                y = j;
            }
        }
    }
    const ox = x;
    const oy = y;
    const visited = u.mapc(lines, false);
    var fvisited: [4][][]bool = undefined;
    for (0..4) |i| {
        fvisited[i] = u.mapc(lines, false);
    }
    while (true) {
        if (!visited[x][y]) {
            visited[x][y] = true;
            s1 += 1;
        }
        const nx = x +% dxs[facing];
        const ny = y +% dys[facing];
        if (nx >= lines.len or ny >= lines[0].len) {
            break;
        }
        if (lines[nx][ny] == '#') {
            facing = (facing + 1) % 4;
        } else {
            x = nx;
            y = ny;
        }
    }
    for (0..lines.len) |i| {
        for (0..lines[0].len) |j| {
            if (i == ox and j == oy) {
                continue;
            }
            x = ox;
            y = oy;
            facing = 0;
            for (fvisited) |fvs| {
                for (fvs) |fv| {
                    @memset(fv, false);
                }
            }
            while (true) {
                if (i == 6 and j == 3) {
                    //std.debug.print("facing: {d} x: {d} y: {d}\n", .{ facing, x, y });
                }
                if (fvisited[facing][x][y]) {
                    s2 += 1;
                    break;
                }
                fvisited[facing][x][y] = true;
                const nx = x +% dxs[facing];
                const ny = y +% dys[facing];
                if (nx >= lines.len or ny >= lines[0].len) {
                    break;
                }
                if (lines[nx][ny] == '#' or (nx == i and ny == j)) {
                    facing = (facing + 1) % 4;
                } else {
                    x = nx;
                    y = ny;
                }
            }
        }
    }
            




    return .{ s1, s2 };
}
