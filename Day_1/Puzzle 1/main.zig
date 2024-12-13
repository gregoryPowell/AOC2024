const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";

    // Read file
    const content = try read_file(allocator, file_name);

    // Parse file input to get rid of unwanted data
    const parsed_buf = try parse_data(allocator, content);

    // Generate ArrayLists to seperate data for each list
    var list_1 = std.ArrayList(i32).init(allocator);
    defer list_1.deinit();
    var list_2 = std.ArrayList(i32).init(allocator);
    defer list_2.deinit();

    // Seperate parsed data into 2 lists
    for (parsed_buf, 0..) |numbers, i| {
        const num = try std.fmt.parseInt(i32, numbers, 10);

        if (i % 2 == 0) {
            try list_1.append(num);
        } else {
            try list_2.append(num);
        }
    }

    // sort both lists into ascending order
    std.mem.sort(i32, list_1.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_2.items, {}, std.sort.asc(i32));

    var summed_diff: u64 = 0;
    for (list_1.items, list_2.items) |item1, item2| {
        summed_diff += @abs(item1 - item2); // find the distance between both items
    }

    // Print resulted distances
    std.debug.print("difference is {d}\n", .{summed_diff});
}

fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

fn parse_data(
    allocator: std.mem.Allocator,
    input_buf: []const u8,
) ![][]const u8 {
    var tokens = std.mem.tokenizeAny(u8, input_buf, " \t\n\r");
    var parsed_buf = std.ArrayList([]const u8).init(allocator);

    while (tokens.next()) |token| {
        const owned_token = try allocator.dupe(u8, token);
        try parsed_buf.append(owned_token);
    }

    return parsed_buf.items;
}
