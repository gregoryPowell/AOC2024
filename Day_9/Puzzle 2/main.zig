const std = @import("std");

const file_path = "input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());

    var index: usize = 0;
    var original_file_system = std.ArrayList(?u64).init(allocator);
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
    // std.debug.print("{d}\n", .{original_file_system.items});
    var file_system = try original_file_system.toOwnedSlice();
    std.debug.print("{any}\n", .{file_system});

    try sort_files(&file_system);
    std.debug.print("{any}\n", .{file_system});

    var checksum: u64 = 0;
    for (file_system, 0..) |elem, i| {
        if (elem != null) {
            checksum += (elem.? * i);
        }
    }
    std.debug.print("checksum is {d}\n", .{checksum});
}

pub fn sort_files(file_sys: *[]?u64) !void {
    const files = file_sys.*;

    var i: usize = files.len;
    var counter: usize = 0;
    var new_elem: u64 = undefined;
    while (i > 1) {
        i -= 1;
        if (files[i] != null) {
            new_elem = files[i].?;
            counter += 1;
            var j = i;
            while (j > 0) {
                j -= 1;
                if (new_elem == files[j]) {
                    counter += 1;
                } else {
                    i = j + 1;
                    break;
                }
            }

            var null_counter: usize = 0;
            for (files, 0..) |elem, k| {
                if (elem == null) {
                    null_counter += 1;
                } else {
                    null_counter = 0;
                }

                if (null_counter == counter) {
                    while (null_counter > 0) : (null_counter -= 1) {
                        if ((k - null_counter + 1) < (j + null_counter)) {
                            files[k - null_counter + 1] = new_elem;
                            files[j + null_counter] = null;
                        }
                        // std.debug.print("{any}\n", .{files});
                    }
                    break;
                }
            }
            counter = 0;
        }
    }
}

const Disk = struct {
    id: usize = undefined,
    files: u8 = undefined,
    free_space: u8 = undefined,
    file_array: std.ArrayList(?u64) = undefined,

    pub fn init(allocator: std.mem.Allocator, id: usize, files: u8, free_space: u8) !Disk {
        var disk: Disk = undefined;
        disk.id = id;
        disk.files = files - 0x30;
        disk.free_space = free_space - 0x30;
        disk.file_array = std.ArrayList(?u64).init(allocator);

        for (0..disk.files) |_| {
            try disk.file_array.append(disk.id);
        }
        for (0..disk.free_space) |_| {
            try disk.file_array.append(null);
        }

        return disk;
    }

    pub fn deinit(self: *Disk) void {
        self.file_array.deinit();
    }
};
