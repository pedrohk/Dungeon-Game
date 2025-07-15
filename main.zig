const std = @import("std");

pub fn calculateMinimumHP(dungeon: [][]const i32) !i32 {
    const m = dungeon.len;
    if (m == 0) return 1;
    const n = dungeon[0].len;
    if (n == 0) return 1;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var dp = try allocator.alloc([]i32, m);
    for (0..m) |i| {
        dp[i] = try allocator.alloc(i32, n);
    }

    var r: usize = m;
    while (r > 0) : (r -= 1) {
        const i = r - 1;
        var c: usize = n;
        while (c > 0) : (c -= 1) {
            const j = c - 1;

            if (i == m - 1 and j == n - 1) {
                dp[i][j] = @max(1, 1 - dungeon[i][j]);
            } else if (i == m - 1) {
                dp[i][j] = @max(1, dp[i][j + 1] - dungeon[i][j]);
            } else if (j == n - 1) {
                dp[i][j] = @max(1, dp[i + 1][j] - dungeon[i][j]);
            } else {
                const min_next_hp = @min(dp[i + 1][j], dp[i][j + 1]);
                dp[i][j] = @max(1, min_next_hp - dungeon[i][j]);
            }
        }
    }

    return dp[0][0];
}

test "Exemplo 1 do LeetCode" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const dungeon_data = [_][3]i32{
        .{ -2, -3, 3 },
        .{ -5, -10, 1 },
        .{ 10, 30, -5 },
    };
    var dungeon_slices = try allocator.alloc([]const i32, 3);
    dungeon_slices[0] = dungeon_data[0][0..];
    dungeon_slices[1] = dungeon_data[1][0..];
    dungeon_slices[2] = dungeon_data[2][0..];

    const min_hp = try calculateMinimumHP(dungeon_slices);
    try std.testing.expectEqual(min_hp, 7);
}

test "Masmorra simples" {
    const dungeon_data = [_][1]i32{
        .{100},
    };
    var dungeon_slices: [1][]const i32 = .{
        dungeon_data[0][0..],
    };
    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra com um único valor negativo" {
    const dungeon_data = [_][]const i32{
        &.{-10},
    };
    var dungeon_slices: [1][]const i32 = .{
        dungeon_data[0][0..],
    };
    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 11);
}

test "Masmorra com zero" {
    const dungeon_data = [_][]const i32{
        &.{0},
    };
    var dungeon_slices: [1][]const i32 = .{
        dungeon_data[0][0..],
    };
    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra 2x2" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();
    const dungeon_data = [_][]const i32{
        &.{ -1, -2 },
        &.{ -3, -4 },
    };
    var dungeon_slices = try allocator.alloc([]const i32, 2);
    dungeon_slices[0] = dungeon_data[0][0..];
    dungeon_slices[1] = dungeon_data[1][0..];

    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 8);
}

test "Masmorra grande com muitos valores positivos" {
    const dungeon_data = [_][]const i32{
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
    };
    var dungeon_slices: [1][]const i32 = .{
        dungeon_data[0][0..],
    };
    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra com caminho desafiador" {
    const dungeon_data = [_][]const i32{
        &.{ 1, -3, 3 },
        &.{ 0, -2, 0 },
        &.{ -3, -3, -3 },
    };
    var dungeon_slices: [1][]const i32 = .{
        dungeon_data[0][0..],
    };
    const min_hp = try calculateMinimumHP(dungeon_slices[0..]);
    try std.testing.expectEqual(min_hp, 3);
}
