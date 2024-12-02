const std = @import("std");

pub var gpa: std.mem.Allocator = undefined;

pub fn alloc(comptime T: type, n: usize) []T {
    return gpa.alloc(T, n) catch @panic("out of memory");
}

pub fn swap(a: anytype, b: anytype) void {
    const tmp = b.*;
    b.* = a.*;
    a.* = tmp;
}

pub fn trimSplit2(s_: []const u8, d: u8) struct{[]const u8, []const u8} {
    var s = s_;
    while (s.len > 0 and s[0] == d) s = s[1..];
    while (s.len > 0 and s[s.len - 1] == d) s = s[0..s.len - 1];
    var list = std.ArrayList([]const u8).init(gpa);
    defer list.deinit();
    var i: usize = 0;
    var start: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == d) {
            list.append(s[start..i]) catch @panic("out of memory");
            start = i + 1;
            break;
        }
    }
    list.append(s[start..]) catch @panic("out of memory");
    if (list.items.len < 2) {
        start = s.len - 1;
        list.append(s[start..]) catch @panic("out of memory");
    }
    return .{ list.items[0], list.items[1] };
}

pub fn split(s_: []const u8, d: u8) [][]const u8 {
    var s = s_;
    var list = std.ArrayList([]const u8).init(gpa);
    defer list.deinit();
    var i: usize = 0;
    var start: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == d) {
            list.append(s[start..i]) catch @panic("out of memory");
            start = i + 1;
        }
    }
    list.append(s[start..]) catch @panic("out of memory");
    return list.toOwnedSlice() catch @panic("out of memory");
}

pub fn trimSplit(s_: []const u8, d: u8) [][]const u8 {
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
                list.append(s[start..i]) catch @panic("out of memory");
            }
            start = i + 1;
        }
    }
    if (start < s.len) {
        list.append(s[start..]) catch @panic("out of memory");
    }
    return list.toOwnedSlice() catch @panic("out of memory");
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

pub fn sortCmp(xs: anytype, f: anytype) void {
    if (@TypeOf(f) == type) {
        return sortCmp(xs, f.lessThan);
    }
    const C = struct {
        slice: @TypeOf(xs),
        pub fn lessThan(self: @This(), i: usize, j: usize) bool {
            return f(self.slice[i], self.slice[j]);
        }
        pub fn swap(self: @This(), i: usize, j: usize) void {
            const tmp = self.slice[i];
            self.slice[i] = self.slice[j];
            self.slice[j] = tmp;
        }
    };
    const c = C{ .slice = xs };
    std.sort.pdqContext(0, xs.len, c);
}

pub fn ascBy(comptime fieldname: []const u8) type {
    return struct {
        pub fn lessThan(a: anytype, b: anytype) bool {
            return @field(a, fieldname) < @field(b, fieldname);
        }
    };
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

pub fn sorted(xs: anytype) @TypeOf(xs) {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    switch (info.pointer.size) {
        .Slice => {
            const ret = gpa.alloc(C, xs.len) catch @panic("out of memory");
            @memcpy(ret, xs);
            std.sort.pdq(C, ret, void{}, std.sort.asc(C));
            return ret;
        },
        else => comptime unreachable,
    }
}

pub fn reversed(xs: anytype) @TypeOf(xs) {
    const T = @TypeOf(xs);
    const info = @typeInfo(T);
    const C = std.meta.Child(T);
    switch (info.pointer.size) {
        .Slice => {
            const ret = gpa.alloc(C, xs.len) catch @panic("out of memory");
            @memcpy(ret, xs);
            std.mem.reverse(C, ret);
            return ret;
        },
        else => comptime unreachable,
    }
}

pub fn fill(comptime T: type, x: anytype, middle: ?T, n: usize) T {
    const C = std.meta.Child(T);
    const this_len = if (middle) |i| i.len else 0;
    const ret = gpa.alloc(C, this_len + 2 * n) catch @panic("out of memory");
    const bottom = comptime (ptrDepth(C) == ptrDepth(@TypeOf(x)));
    if (bottom) {
        for (ret) |*i| {
            i.* = x;
        }
    } else {
        const inner: ?C = if (middle) |i| if (i.len > 0) i[0] else null else null;
        for (ret) |*i| {
            i.* = fill(C, x, inner, n);
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

pub fn pad(xs: anytype, sentinel: anytype, n: usize) @TypeOf(xs) {
    const T = @TypeOf(xs);
    const C = std.meta.Child(T);
    const ret = gpa.alloc(C, xs.len + n * 2) catch @panic("out of memory");
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
            ret[i] = fill(C, sentinel, inner, n);
        }
        for (xs.len..ret.len) |i| {
            ret[i] = fill(C, sentinel, inner, n);
        }
    }
    if (bottom) {
        for (0..xs.len) |i| {
            ret[i+n] = xs[i];
        }
    } else {
        for (0..xs.len) |i| {
            ret[i+n] = pad(xs[i], sentinel, n);
        }
    }
    return ret;
}

fn typeResemblesFieldname(T: type) bool {
    const info = @typeInfo(T);
    if (info == .pointer and
    info.pointer.size == .One) {
        const cinfo = @typeInfo(info.pointer.child);
        if (cinfo == .array and
        cinfo.array.child == u8 and
        cinfo.array.sentinel != null) {
            return true;
        }
    }
    return false;
}

pub fn getSliceType(T: type, f: anytype) type {
    const F = @TypeOf(f);
    if (comptime typeResemblesFieldname(F)) {
        const xd = ptrDepth(T);
        var ret = @FieldType(getElemType(T), f);
        for (0..xd) |_| {
            ret = []ret;
        }
        return ret;
    }
    if (F != type) {
        return getSliceType(T, F);
    }
    const info = @typeInfo(f);
    const Return = info.@"fn".return_type.?;
    const Param1 = info.@"fn".params[0].type.?;
    const bottom = comptime (ptrDepth(T) == ptrDepth(Param1));
    if (bottom) {
        const return_info = @typeInfo(Return);
        switch (return_info) {
            .error_union => {
                return return_info.error_union.payload;
            },
            else => {
                return Return;
            },
        }
    } else {
        const C = std.meta.Child(T);
        return []getSliceType(C, f);
    }
}

pub fn getElemType(T: anytype) type {
    if (@TypeOf(T) != type) {
        return getElemType(@TypeOf(T));
    }
    const info = @typeInfo(T);
    switch (info) {
        .pointer => |ptr| return ptr.child,
        else => return T,
    }
}

pub fn field(comptime T: type, comptime fieldname: []const u8) fn(T) @FieldType(T, fieldname) {
    return struct {
        fn f(x: T) @FieldType(T, fieldname) {
            return @field(x, fieldname);
        }
    }.f;
}

pub inline fn map(xs: anytype, f: anytype) getSliceType(@TypeOf(xs), if (@typeInfo(@TypeOf(.{ f })).@"struct".fields[0].is_comptime) f else @TypeOf(f)) {
    if (comptime typeResemblesFieldname(@TypeOf(f))) {
        return map(xs, field(getElemType(@TypeOf(xs)), f));
    }
    const T = @TypeOf(xs);
    const F = @TypeOf(f);
    const info = @typeInfo(F);
    const Param1 = info.@"fn".params[0].type.?;
    const Return = info.@"fn".return_type.?;
    const bottom = comptime (ptrDepth(T) == ptrDepth(Param1));
    if (bottom) {
        const return_info = @typeInfo(Return);
        switch (return_info) {
            .error_union => {
                return f(xs) catch @panic("map failed");
            },
            else => {
                return f(xs);
            },
        }
    } else {
        const SliceType = getSliceType(@TypeOf(xs), f);
        const ElemType = std.meta.Child(SliceType);
        const ret = gpa.alloc(ElemType, xs.len) catch @panic("alloc failed");
        for (xs, 0..) |x, i| {
            ret[i] = map(x, f);
        }
        return ret;
    }
}

pub fn reduce(xs: anytype, f: anytype, initial: anytype) @typeInfo(@TypeOf(f)).@"fn".return_type.? {
    const T = @TypeOf(xs);
    const F = @TypeOf(f);
    const info = @typeInfo(F);
    const Param2 = info.@"fn".params[1].type.?;
    const Param1 = info.@"fn".params[0].type.?;
    const Return = info.@"fn".return_type.?;
    const bottom = comptime (ptrDepth(T) == ptrDepth(Param2));
    if (bottom) {
        const return_info = @typeInfo(Return);
        switch (return_info) {
            .error_union => {
                return f(initial, xs) catch @panic("map failed");
            },
            else => {
                return f(initial, xs);
            },
        }
    } else {
        var ret: Param1 = initial;
        for (xs) |x| {
            ret = reduce(x, f, ret);
        }
        return ret;
    }
}

pub fn min(xs: anytype) getElemType(@TypeOf(xs)) {
    const T = getElemType(@TypeOf(xs));
    return reduce(xs, struct{pub fn min(a: T, b: T) T { return @min(a,b); }}.min, std.math.maxInt(T));
}

pub fn max(xs: anytype) getElemType(@TypeOf(xs)) {
    const T = getElemType(@TypeOf(xs));
    return reduce(xs, struct{pub fn max(a: T, b: T) T { return @max(a,b); }}.max, std.math.minInt(T));
}

pub fn group2(xs: anytype) []struct{getElemType(@TypeOf(xs)), getElemType(@TypeOf(xs))} {
    const T = getElemType(@TypeOf(xs));
    if (xs.len % 2 != 0) @panic("group2: xs.len must be even");
    const ret = gpa.alloc(struct{T, T}, xs.len/2) catch @panic("group2: alloc failed");
    for (0..ret.len) |i| {
        ret[i][0] = xs[i*2];
        ret[i][1] = xs[i*2+1];
    }
    return ret;
}

pub fn trimSplitParse2(s: []const u8, delim: u8) struct{i64, i64} {
    const ret = trimSplitParse(s, delim);
    return .{ ret[0], ret[1] };
}

pub fn trimSplitParse3(s: []const u8, delim: u8) struct{i64, i64, i64} {
    const ret = trimSplitParse(s, delim);
    return .{ ret[0], ret[1], ret[2] };
}

pub fn trimSplitParse4(s: []const u8, delim: u8) struct{i64, i64, i64, i64} {
    const ret = trimSplitParse(s, delim);
    return .{ ret[0], ret[1], ret[2], ret[3] };
}

pub fn trimSplitParse5(s: []const u8, delim: u8) struct{i64, i64, i64, i64, i64} {
    const ret = trimSplitParse(s, delim);
    return .{ ret[0], ret[1], ret[2], ret[3], ret[4] };
}

pub fn trimSplitParse(s: []const u8, delim: u8) []i64 {
    return trimSplitParseBase(s, delim, 10);
}

pub fn trimSplitParseBase(s: []const u8, delim: u8, base: u8) []i64 {
    const strs = trimSplit(s, delim);
    const ret = gpa.alloc(i64, strs.len) catch @panic("alloc failed");
    for (strs, 0..) |str, i| {
        ret[i] = std.fmt.parseInt(i64, str, base) catch @panic("parse failed");
    }
    return ret;
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