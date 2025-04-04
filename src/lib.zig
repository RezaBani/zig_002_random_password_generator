const std = @import("std");

pub const CharacterType = enum(u8) { Symbol = 0, AlphabetUpper = 1, AlphabetLower = 2, Number = 3 };

pub const SYMBOLS = "!@#$%&*()?/[]{}-+_=<>.,";
pub const ALPHABETUPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
pub const ALPHABETLOWER = "abcdefghijklmnopqrstuvwxyz";
pub const NUMBERS = "0123456789";

pub fn generate_random_password(allocator: std.mem.Allocator, length: u8) ![]u8 {
    std.debug.assert(length > 3);
    var result = try allocator.alloc(u8, length);
    @memset(result, 0);
    var choices: [4]u8 = undefined;
    @memset(&choices, 0);
    const time = std.time.timestamp();
    var seed = std.Random.DefaultPrng.init(@intCast(time));
    const random = std.Random.DefaultPrng.random(&seed);
    for (0..length) |i| {
        choices[@intFromEnum(CharacterType.Symbol)] = SYMBOLS[random.intRangeAtMost(u8, 0, SYMBOLS.len - 1)];
        choices[@intFromEnum(CharacterType.AlphabetUpper)] = random.intRangeAtMost(u8, 'A', 'Z');
        choices[@intFromEnum(CharacterType.AlphabetLower)] = random.intRangeAtMost(u8, 'a', 'z');
        choices[@intFromEnum(CharacterType.Number)] = random.intRangeAtMost(u8, '0', '9');
        const choice = if (result[0] == 0)
            random.intRangeAtMost(u8, 0, choices.len - 1)
        else if (!contains_at_least_once(result, SYMBOLS))
            @intFromEnum(CharacterType.Symbol)
        else if (!contains_at_least_once(result, ALPHABETUPPER))
            @intFromEnum(CharacterType.AlphabetUpper)
        else if (!contains_at_least_once(result, ALPHABETLOWER))
            @intFromEnum(CharacterType.AlphabetLower)
        else if (!contains_at_least_once(result, NUMBERS))
            @intFromEnum(CharacterType.Number)
        else
            random.intRangeAtMost(u8, 0, choices.len - 1);
        result[i] = choices[choice];
    }
    return result;
}

pub fn contains_at_least_once(password: []const u8, characters: []const u8) bool {
    for (characters) |character| {
        const needle = [_]u8{character};
        if (std.mem.containsAtLeast(u8, password, 1, &needle)) {
            return true;
        }
    }
    return false;
}
