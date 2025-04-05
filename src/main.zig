const std = @import("std");
const lib = @import("zig_002_password_generator_lib");

pub const ArgsError = error{
    TooManyArgs,
};

pub const ArgumentsOrder = enum(usize) {
    // ExecutableName = 0,
    Length = 1,
};

pub const CommandLineArguments = struct {
    length: u8,
};

pub const DEFAULT_LENGTH: u8 = 16;
pub const MAX_ARGS_COUNT: usize = 2;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const rawArgs = readArgs(allocator) catch |err| switch (err) {
        std.mem.Allocator.Error.OutOfMemory => {
            std.debug.print("{}\n", .{err});
            std.debug.print("Not enough emory to store args", .{});
            std.process.exit(1);
        },
    };
    const args = parseArgs(rawArgs) catch |err| switch (err) {
        ArgsError.TooManyArgs => {
            std.debug.print("{}\n", .{err});
            std.debug.print("This executable accepts only {d} arguments but more than {d} argument is provided!\n", .{ MAX_ARGS_COUNT - 1, MAX_ARGS_COUNT - 1 });
            std.process.exit(1);
        },
        std.fmt.ParseIntError.InvalidCharacter => {
            std.debug.print("{}\n", .{err});
            std.debug.print("argument {s} can't be converted to unsigned interger\n", .{rawArgs[@intFromEnum(ArgumentsOrder.Length)]});
            std.process.exit(1);
        },
        std.fmt.ParseIntError.Overflow => {
            std.debug.print("{}\n", .{err});
            std.debug.print("argument {s} too big when converted to unsigned interger\n", .{rawArgs[@intFromEnum(ArgumentsOrder.Length)]});
            std.process.exit(1);
        },
    };
    const password = lib.generate_random_password(allocator, args.length) catch |err| switch (err) {
        std.mem.Allocator.Error.OutOfMemory => {
            std.debug.print("{}\n", .{err});
            std.debug.print("Not enough emory to store password", .{});
            std.process.exit(1);
        },
    };
    defer allocator.free(password);
    std.debug.print("{s}\n", .{password});
}

fn readArgs(allocator: std.mem.Allocator) ![][]const u8 {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    var argsArray = std.ArrayList([]const u8).init(allocator);
    while (args.next()) |arg| {
        const buf = try allocator.alloc(u8, arg.len);
        @memcpy(buf, arg);
        try argsArray.append(buf);
    }
    const slice = try argsArray.toOwnedSlice();
    return slice;
}

pub fn parseArgs(args: [][]const u8) !CommandLineArguments {
    if (args.len > MAX_ARGS_COUNT) {
        return ArgsError.TooManyArgs;
    }
    const length = if (args.len > 1)
        try std.fmt.parseUnsigned(u8, args[@intFromEnum(ArgumentsOrder.Length)], 10)
    else
        DEFAULT_LENGTH;
    return CommandLineArguments{
        .length = length,
    };
}
