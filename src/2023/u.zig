const std = @import("std");

pub var a: std.mem.Allocator = undefined;

pub fn trimSplit2(s_: []const u8, d: u8) ![][]const u8 {
    var s = s_;
    while (s.len > 0 and s[0] == d) s = s[1..];
    while (s.len > 0 and s[s.len - 1] == d) s = s[0..s.len - 1];
    var list = std.ArrayList([]const u8).init(a);
    defer list.deinit();
    var i: usize = 0;
    var start: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == d) {
            try list.append(s[start..i]);
            start = i + 1;
            break;
        }
    }
    try list.append(s[start..]);
    if (list.items.len < 2) {
        start = s.len - 1;
        try list.append(s[start..]);
    }
    return list.toOwnedSlice();
}

pub fn trimSplit(s_: []const u8, d: u8) ![][]const u8 {
    var s = s_;
    while (s.len > 0 and s[0] == d) s = s[1..];
    while (s.len > 0 and s[s.len - 1] == d) s = s[0..s.len - 1];
    var list = std.ArrayList([]const u8).init(a);
    defer list.deinit();
    var i: usize = 0;
    var start: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == d) {
            try list.append(s[start..i]);
            start = i + 1;
        }
    }
    try list.append(s[start..]);
    return list.toOwnedSlice();
}

pub fn sort(xs: anytype) void {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    //const child_info = @typeInfo(C);
    switch (info.Pointer.size) {
        .Slice => {
            std.sort.pdq(C, xs, void{}, std.sort.asc(C));
        },
        else => comptime unreachable,
    }
}

pub fn reverse(xs: anytype) void {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    //const child_info = @typeInfo(C);
    switch (info.Pointer.size) {
        .Slice => {
            std.mem.reverse(C, a);
        },
        else => comptime unreachable,
    }
}

pub fn use(aa: anytype, b: anytype) void {
    _ = aa;
    _ = b;
}