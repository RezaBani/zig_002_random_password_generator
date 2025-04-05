const std = @import("std");
const exe = @import("zig_002_password_generator_exe");
const lib = @import("zig_002_password_generator_lib");

test "lib test" {
    const length = 20;
    const allocator = std.testing.allocator;
    const password = try lib.generate_random_password(allocator, length);
    defer allocator.free(password);
    try std.testing.expect(password.len == length);
    try test_contains_at_least(password);
}

test "main test" {
    const allocator = std.testing.allocator;

    const argumentSetOkEmpty: [][]const u8 = @constCast(&[_][]const u8{"executableName"});
    const argumentSetOkOne: [][]const u8 = @constCast(&[_][]const u8{ "executableName", "20" });
    const argumentSetBad: [][]const u8 = @constCast(&[_][]const u8{ "executableName", "garbage" });
    const argumentSetBadExtra: [][]const u8 = @constCast(&[_][]const u8{ "executableName", "20", "extra" });

    try std.testing.expectEqual(exe.DEFAULT_LENGTH, (try exe.parseArgs(argumentSetOkEmpty)).length);
    try std.testing.expectEqual(try std.fmt.parseUnsigned(usize, argumentSetOkOne[@intFromEnum(exe.ArgumentsOrder.Length)], 10), (try exe.parseArgs(argumentSetOkOne)).length);
    try std.testing.expectError(std.fmt.ParseIntError.InvalidCharacter, exe.parseArgs(argumentSetBad));
    try std.testing.expectError(exe.ArgsError.TooManyArgs, exe.parseArgs(argumentSetBadExtra));

    var okArgs = std.ArrayList([][]const u8).init(allocator);
    defer okArgs.deinit();
    try okArgs.append(argumentSetOkOne);
    try okArgs.append(argumentSetOkEmpty);
    for (okArgs.items) |rawArgs| {
        const args = try exe.parseArgs(rawArgs);
        const password = try lib.generate_random_password(allocator, args.length);
        defer allocator.free(password);
        try std.testing.expectEqual(password.len, args.length);
        try test_contains_at_least(password);
    }
}

fn test_contains_at_least(password: []const u8) !void {
    try std.testing.expect(lib.contains_at_least_once(password, lib.SYMBOLS));
    try std.testing.expect(lib.contains_at_least_once(password, lib.ALPHABETUPPER));
    try std.testing.expect(lib.contains_at_least_once(password, lib.ALPHABETLOWER));
    try std.testing.expect(lib.contains_at_least_once(password, lib.NUMBERS));
}
