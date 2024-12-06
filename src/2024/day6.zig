const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part12() !struct{?i128, ?i128} {
    var lines_ = u.trimSplit(input, '\n');
    const input_: []u8 = u.alloc(u8, input.len);
    @memcpy(input_, input);
    const lines = u.trimSplit(input_, '\n');
    var s1: i64 = 0;
    var s2: i64 = 0;
    u.use3(&s1, &s2, &lines_);
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
    const exx: []u16 = u.alloc(u16, lines.len * lines[0].len);
    const exy: []u16 = u.alloc(u16, lines.len * lines[0].len);
    const exf: []u16 = u.alloc(u16, lines.len * lines[0].len);
    const rocked: [][]bool = u.alloc([]bool, lines.len);
    for (0..lines.len) |i| {
        rocked[i] = u.alloc(bool, lines[0].len);
        @memset(rocked[i], false);
    }
    rocked[ox][oy] = true;
    while (true) {
        if (!visited[x][y]) {
            visited[x][y] = true;
            s1 += 1;
        }
        fvisited[facing][x][y] = true;
        const nx = x +% dxs[facing];
        const ny = y +% dys[facing];
        if (nx >= lines.len or ny >= lines[0].len) {
            break;
        }
        if (lines[nx][ny] == '#') {
            facing = (facing + 1) % 4;
        } else {
            if (!rocked[nx][ny]) {
                const restore_facing = facing;
                facing = (facing + 1) % 4;
                rocked[nx][ny] = true;
                lines[nx][ny] = '#';
                var nex: usize = 0;
                while (true) {
                    if (fvisited[facing][x][y]) {
                        s2 += 1;
                        break;
                    }
                    fvisited[facing][x][y] = true;
                    const enx = x +% dxs[facing];
                    const eny = y +% dys[facing];
                    exx[nex] = @truncate(x);
                    exy[nex] = @truncate(y);
                    exf[nex] = @truncate(facing);
                    nex += 1;
                    if (enx >= lines.len or eny >= lines[0].len) {
                        break;
                    }
                    if (lines[enx][eny] == '#') {
                        facing = (facing + 1) % 4;
                    } else {
                        x = enx;
                        y = eny;
                    }
                }
                for (0..nex) |i| {
                    const rf = exf[i];
                    const rx = exx[i];
                    const ry = exy[i];
                    fvisited[rf][rx][ry] = false;
                }
                facing = restore_facing;
                lines[nx][ny] = '.';
            }
            x = nx;
            y = ny;
        }
    }
    return .{ s1, s2 };
}
