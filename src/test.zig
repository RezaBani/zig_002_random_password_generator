const std = @import("std");

const lib = @import("lib.zig");

test "simple test" {
    const length = 20;
    const allocator = std.testing.allocator;
    const password = try lib.generate_random_password(allocator, length);
    defer allocator.free(password);
    try std.testing.expect(password.len == length);
    try std.testing.expect(lib.contains_at_least_once(password, lib.SYMBOLS));
    try std.testing.expect(lib.contains_at_least_once(password, lib.ALPHABETUPPER));
    try std.testing.expect(lib.contains_at_least_once(password, lib.ALPHABETLOWER));
    try std.testing.expect(lib.contains_at_least_once(password, lib.NUMBERS));
}
