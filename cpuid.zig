const std = @import("std");
const builtin = @import("builtin");
const target = std.Target.Cpu.Arch;
const eql = std.mem.eql;
const test_allocator = std.testing.allocator;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var feats = [_][]const u8{ "sse", "sse2", "sse3" };

    var buffer: [100]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;

    if (features(allocator, feats[0..])) |res| {
        std.debug.print("Success: {s}\n", .{res});
    } else |err| switch (err) {
        else => std.debug.print("Error: {any}", .{err}),
    }
}

pub fn features(allocator: *Allocator, flags: [][]const u8) ![][]const u8 {
    const result = try allocator.alloc([]const u8, flags.len);

    std.mem.copy([]const u8, result, flags);

    var buffer: [100]u8 = undefined;
    const dummy = buffer[0..];
    const all_features = target.allFeaturesList(builtin.target.cpu.arch);

    for (all_features) |instruction| {
        if (std.fmt.bufPrint(dummy, "{s}", .{instruction.name})) |inst| {
            for (result) |flag, index| {
                if (eql(u8, flag, inst)) {
                    result[index] = flag;
                }
            }
        } else |err| switch (err) {
            else => std.debug.print("{any}", .{err}),
        }
    }

    return result;
}