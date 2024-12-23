const std = @import("std");

const file_path = "test_input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());
    std.debug.print("{s}", .{content});

    var index: usize = 0;
    var original_file_system = std.ArrayList(u8).init(allocator);
    defer original_file_system.deinit();

    while (index < content.len) : (index += 2) {
        var free_space: u8 = 0x30;
        if (index + 1 < content.len - 1) {
            free_space = content[index + 1];
        }
        var new_disk = try Disk.init(allocator, index / 2, content[index], free_space);
        defer new_disk.deinit();

        try original_file_system.appendSlice(try new_disk.file_array.toOwnedSlice());
    }
    std.debug.print("{s}\n", .{original_file_system.items});
    var file_system = try original_file_system.toOwnedSlice();

    for (file_system, 0..) |elem, i| {
        if (elem == '.') {
            var j = file_system.len - 1;
            while (j >= i) : (j -= 1) {
                if (file_system[j] != '.') {
                    file_system[i] = file_system[j];
                    file_system[j] = '.';
                    break;
                }
            }
            if (j <= i) break;
            std.debug.print("{s}\n", .{file_system});
        }
    }

    var checksum: u64 = 0;
    for (file_system, 0..) |elem, i| {
        if (elem != '.') {
            checksum += ((elem - 0x30) * i);
        }
    }
    std.debug.print("checksum is {d}\n", .{checksum});
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
