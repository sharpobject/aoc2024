const std = @import("std");

pub var gpa: std.mem.Allocator = undefined;

pub fn trimSplit2(s_: []const u8, d: u8) !struct{[]const u8, []const u8} {
    var s = s_;
    while (s.len > 0 and s[0] == d) s = s[1..];
    while (s.len > 0 and s[s.len - 1] == d) s = s[0..s.len - 1];
    var list = std.ArrayList([]const u8).init(gpa);
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
    return .{ list.items[0], list.items[1] };
}

pub fn tokenize(s_: []const u8, d: u8) ![][]const u8 {
    var s = s_;
    var list = std.ArrayList([]const u8).init(gpa);
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

pub fn trimSplit(s_: []const u8, d: u8) ![][]const u8 {
    var s = s_;
    while (s.len > 0 and s[0] == d) s = s[1..];
    while (s.len > 0 and s[s.len - 1] == d) s = s[0..s.len - 1];
    var list = std.ArrayList([]const u8).init(gpa);
    defer list.deinit();
    var i: usize = 0;
    var start: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == d) {
            if (start < i) {
                try list.append(s[start..i]);
            }
            start = i + 1;
        }
    }
    if (start < s.len) {
        try list.append(s[start..]);
    }
    return list.toOwnedSlice();
}

pub fn sort(xs: anytype) void {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    switch (info.pointer.size) {
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
    switch (info.pointer.size) {
        .Slice => {
            std.mem.reverse(C, xs);
        },
        else => comptime unreachable,
    }
}

pub fn sorted(xs: anytype) !@TypeOf(xs) {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    switch (info.pointer.size) {
        .Slice => {
            const ret = try gpa.alloc(C, xs.len);
            @memcpy(ret, xs);
            std.sort.pdq(C, ret, void{}, std.sort.asc(C));
            return ret;
        },
        else => comptime unreachable,
    }
}

pub fn reversed(xs: anytype) !@TypeOf(xs) {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    switch (info.pointer.size) {
        .Slice => {
            const ret = try gpa.alloc(C, xs.len);
            @memcpy(ret, xs);
            std.mem.reverse(C, ret);
            return ret;
        },
        else => comptime unreachable,
    }
}

pub fn fill(comptime T: type, x: anytype, middle: ?T, n: usize) !T {
    const C = std.meta.Child(T);
    const this_len = if (middle) |i| i.len else 0;
    const ret = try gpa.alloc(C, this_len + 2 * n);
    const bottom = comptime (ptrDepth(C) == ptrDepth(@TypeOf(x)));
    if (bottom) {
        for (ret) |*i| {
            i.* = x;
        }
    } else {
        const inner: ?C = if (middle) |i| if (i.len > 0) i[0] else null else null;
        for (ret) |*i| {
            i.* = try fill(C, x, inner, n);
        }
    }
    return ret;
}

pub fn ptrDepth(T: type) usize {
    const info = @typeInfo(T);
    switch (info) {
        .pointer => |ptr| return 1 + ptrDepth(ptr.child),
        else => return 0,
    }
}

pub fn pad(xs: anytype, sentinel: anytype, n: usize) !@TypeOf(xs) {
    const T = @TypeOf(xs);
    const C = std.meta.Child(T);
    const ret = try gpa.alloc(C, xs.len + n * 2);
    const inner: ?C = if (xs.len > 0) xs[0] else null;
    const bottom = comptime (ptrDepth(C) == ptrDepth(@TypeOf(sentinel)));
    if (bottom) {
        for (0..n) |i| {
            ret[i] = sentinel;
        }
        for (xs.len..ret.len) |i| {
            ret[i] = sentinel;
        }
    } else {
        for (0..n) |i| {
            ret[i] = try fill(C, sentinel, inner, n);
        }
        for (xs.len..ret.len) |i| {
            ret[i] = try fill(C, sentinel, inner, n);
        }
    }
    if (bottom) {
        for (0..xs.len) |i| {
            ret[i+n] = xs[i];
        }
    } else {
        for (0..xs.len) |i| {
            ret[i+n] = try pad(xs[i], sentinel, n);
        }
    }
    return ret;
}

pub fn getSliceType(T: type, F: type) type {
    const info = @typeInfo(F);
    const Return = info.@"fn".return_type.?;
    const bottom = comptime (ptrDepth(T) == ptrDepth(Return));
    if (bottom) {
        return Return;
    } else {
        const C = std.meta.Child(T);
        return []getSliceType(C, F);
    }
}

pub fn map(xs: anytype, f: anytype) !getSliceType(@TypeOf(xs), @TypeOf(f)) {
    const T = @TypeOf(xs);
    const F = @TypeOf(f);
    const info = @typeInfo(F);
    const Param1 = info.@"fn".params[0].type.?;
    const bottom = comptime (ptrDepth(T) == ptrDepth(Param1));
    if (bottom) {
        return f(xs);
    } else {
        const SliceType = getSliceType(@TypeOf(xs), @TypeOf(f));
        const ElemType = std.meta.Child(SliceType);
        const ret = try gpa.alloc(ElemType, xs.len);
        for (xs, 0..) |x, i| {
            ret[i] = try map(x, f);
        }
        return ret;
    }
}

pub fn widenThenBitCast(comptime T: type, x: anytype) T {
    const U = @TypeOf(x);
    const u_info = @typeInfo(U);
    const t_info = @typeInfo(T);
    if (u_info.int.bits == t_info.int.bits) {
        return @bitCast(x);
    } else {
        return @bitCast(@as(std.meta.Int(.signed, u_info.int.bits), x));
    }
}

pub fn adj(xs: anytype, i: usize, j: usize, comptime dxs: anytype, comptime dys: anytype) [@sizeOf(@TypeOf(dxs))/@sizeOf(@TypeOf(dxs[0]))]@TypeOf(xs[0][0]) {
    var ret: [@sizeOf(@TypeOf(dxs))/@sizeOf(@TypeOf(dxs[0]))]@TypeOf(xs[0][0]) = undefined;
    for (0..dxs.len) |k| {
        const dx: usize = widenThenBitCast(usize, dxs[k]);
        const dy: usize = widenThenBitCast(usize, dys[k]);
        const x: usize = i +% dx;
        const y: usize = j +% dy;
        ret[k] = xs[x][y];
    }
    return ret;
}

pub fn use(aa: anytype, b: anytype) void {
    _ = aa;
    _ = b;
}