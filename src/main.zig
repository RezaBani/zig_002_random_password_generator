const std = @import("std");

const CharacterType = enum(u8) { Symbol = 0, AlphabetUpper = 1, AlphabetLower = 2, Number = 3 };

const SYMBOLS = "!@#$%&*()?/[]{}-+_=<>.,";
const ALPHABETUPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const ALPHABETLOWER = "abcdefghijklmnopqrstuvwxyz";
const NUMBERS = "0123456789";

pub fn generate_random_password(allocator: std.mem.Allocator, length: u8) ![]u8 {
    var result = try allocator.alloc(u8, length);
    @memset(result, 0);
    var choices: [4]u8 = undefined;
    @memset(&choices, 0);
    const random = std.Random.DefaultPrng.random(@constCast(&std.Random.DefaultPrng.init(@intCast(std.time.timestamp()))));
    for (0..length) |i| {
        choices[@intFromEnum(CharacterType.Symbol)] = SYMBOLS[random.intRangeAtMost(u8, 0, SYMBOLS.len - 1)];
        choices[@intFromEnum(CharacterType.AlphabetUpper)] = random.intRangeAtMost(u8, 'A', 'Z');
        choices[@intFromEnum(CharacterType.AlphabetLower)] = random.intRangeAtMost(u8, 'a', 'z');
        choices[@intFromEnum(CharacterType.Number)] = random.intRangeAtMost(u8, '0', '9');
        const choice = if (result[0] == 0)
            random.intRangeAtMost(u8, 0, choices.len - 1)
        else if (!containsAtLeastOnce(result, SYMBOLS))
            @intFromEnum(CharacterType.Symbol)
        else if (!containsAtLeastOnce(result, ALPHABETUPPER))
            @intFromEnum(CharacterType.AlphabetUpper)
        else if (!containsAtLeastOnce(result, ALPHABETLOWER))
            @intFromEnum(CharacterType.AlphabetLower)
        else if (!containsAtLeastOnce(result, NUMBERS))
            @intFromEnum(CharacterType.Number)
        else
            random.intRangeAtMost(u8, 0, choices.len - 1);
        result[i] = choices[choice];
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const password = try generate_random_password(allocator, 16);
    defer allocator.free(password);
    std.debug.print("{s}\n", .{password});
}

test "simple test" {
    const length = 20;
    const allocator = std.testing.allocator;
    const password = try generate_random_password(allocator, length);
    defer allocator.free(password);
    try std.testing.expect(password.len == length);
    try std.testing.expect(containsAtLeastOnce(password, SYMBOLS));
    try std.testing.expect(containsAtLeastOnce(password, ALPHABETUPPER));
    try std.testing.expect(containsAtLeastOnce(password, ALPHABETLOWER));
    try std.testing.expect(containsAtLeastOnce(password, NUMBERS));
}

fn containsAtLeastOnce(password: []const u8, characters: []const u8) bool {
    for (characters) |character| {
        const needle = [_]u8{character};
        if (std.mem.containsAtLeast(u8, password, 1, &needle)) {
            return true;
        }
    }
    return false;
}
