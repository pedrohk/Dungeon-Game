const std = @import("std");

pub fn calculateMinimumHP(dungeon: [][]const i32) !i32 {
    const m = dungeon.len;
    if (m == 0) return 0;
    const n = dungeon[0].len;
    if (n == 0) return 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var dp = try allocator.alloc([*]i32, m);
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
    const dungeon_data = [_][]const i32{
        &.{ -2, -3, 3 },
        &.{ -5, -10, 1 },
        &.{ 10, 30, -5 },
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 7);
}

test "Masmorra simples" {
    const dungeon_data = [_][]const i32{
        &.{100},
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra com um único valor negativo" {
    const dungeon_data = [_][]const i32{
        &.{-10},
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 11);
}

test "Masmorra com zero" {
    const dungeon_data = [_][]const i32{
        &.{0},
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra 2x2" {
    const dungeon_data = [_][]const i32{
        &.{ -1, -2 },
        &.{ -3, -4 },
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 8);
}

test "Masmorra grande com muitos valores positivos" {
    const dungeon_data = [_][]const i32{
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
        &.{ 1, 1, 1, 1 },
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 1);
}

test "Masmorra com caminho desafiador" {
    const dungeon_data = [_][]const i32{
        &.{ 1, -3, 3 },
        &.{ 0, -2, 0 },
        &.{ -3, -3, -3 },
    };
    const min_hp = try calculateMinimumHP(dungeon_data);
    try std.testing.expectEqual(min_hp, 3);
}
