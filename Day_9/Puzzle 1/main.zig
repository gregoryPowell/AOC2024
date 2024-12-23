const std = @import("std");

const file_path = "test_input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());
    std.debug.print("{s}\n", .{content});

    var index: usize = 0;
    var file_system = std.ArrayList(u8).init(allocator);
    defer file_system.deinit();

    while (index < content.len) : (index += 2) {
        var free_space: u8 = 0x30;
        if (index + 1 < content.len - 1) {
            free_space = content[index + 1];
        }
        var new_disk = try Disk.init(allocator, index / 2, content[index], free_space);
        defer new_disk.deinit();

        try file_system.appendSlice(try new_disk.file_array.toOwnedSlice());
    }

    std.debug.print("{s}\n", .{file_system.items});
}

const Disk = struct {
    id: u8 = undefined,
    files: u8 = undefined,
    free_space: u8 = undefined,
    file_array: std.ArrayList(u8) = undefined,

    pub fn init(allocator: std.mem.Allocator, id: usize, files: u8, free_space: u8) !Disk {
        var disk: Disk = undefined;
        disk.id = @intCast(id);
        disk.files = files - 0x30;
        disk.free_space = free_space - 0x30;
        disk.file_array = std.ArrayList(u8).init(allocator);

        for (0..disk.files) |_| {
            try disk.file_array.append(disk.id + 0x30);
        }
        for (0..disk.free_space) |_| {
            try disk.file_array.append('.');
        }

        return disk;
    }

    pub fn deinit(self: *Disk) void {
        self.file_array.deinit();
    }
};
