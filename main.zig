const std = @import("std");

pub const DungeonGame = struct {
    fn f(i: usize, j: usize, dungeon: [][]const i32, dp: [][]i32) i32 {
        const rows = dungeon.len;
        const cols = dungeon[0].len;

        if (i >= rows or j >= cols) {
            return 1_000_000_000;
        }

        if (i == rows - 1 and j == cols - 1) {
            if (dungeon[i][j] < 0) {
                return (std.math.absInt(dungeon[i][j]) catch unreachable) + 1;
            } else {
                return 1;
            }
        }

        if (dp[i][j] != -1) {
            return dp[i][j];
        }

        if (dungeon[i][j] < 0) {
            const cost = std.math.absInt(dungeon[i][j]) catch unreachable;
            const health_from_right = cost + f(i, j + 1, dungeon, dp);
            const health_from_down = cost + f(i + 1, j, dungeon, dp);

            dp[i][j] = std.math.min(health_from_down, health_from_right);
            return dp[i][j];
        } else {
            const health_needed_right = f(i, j + 1, dungeon, dp);
            const health_needed_down = f(i + 1, j, dungeon, dp);

            const balance_right = @as(i64, dungeon[i][j]) - health_needed_right;
            const balance_down = @as(i64, dungeon[i][j]) - health_needed_down;

            if (balance_right >= 0 or balance_down >= 0) {
                dp[i][j] = 1;
                return 1;
            } else {
                const deficit_down = std.math.absInt(balance_down) catch unreachable;
                const deficit_right = std.math.absInt(balance_right) catch unreachable;
                dp[i][j] = @intCast(std.math.min(deficit_down, deficit_right));
                return dp[i][j];
            }
        }
    }

    pub fn calculateMinimumHP(allocator: std.mem.Allocator, dungeon: [][]i32) !i32 {
        const rows = dungeon.len;
        if (rows == 0) return 1;
        const cols = dungeon[0].len;
        if (cols == 0) return 1;

        var dp = try allocator.alloc([]i32, rows);
        defer allocator.free(dp);

        for (0..rows) |i| {
            dp[i] = try allocator.alloc(i32, cols);
            errdefer {
                for (0..i) |j| {
                    allocator.free(dp[j]);
                }
            }
        }
        defer {
            for (dp) |row| {
                allocator.free(row);
            }
        }

        for (dp) |row| {
            std.mem.set(i32, row, -1);
        }

        return f(0, 0, dungeon, dp);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const raw_dungeon = [_][]i32{
        &[_]i32{ -2, -3, 3 },
        &[_]i32{ -5, -10, 1 },
        &[_]i32{ 10, 30, -5 },
    };

    const min_hp = try DungeonGame.calculateMinimumHP(allocator, raw_dungeon);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Minimum HP required: {d}\n", .{min_hp});
}
