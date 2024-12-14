const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    var safe_levels: i64 = 0;

    // Read file
    const content = try read_file(allocator, file_name);

    // Parse file input to get rid of unwanted data
    const parsed_data = try parse_data_by_line(allocator, content);

    // take the parsed lines then parse them further
    for (parsed_data) |levels| {
        const parsed_level = try parse_data(allocator, levels);
        var temp_buffer = std.ArrayList(i32).init(allocator);
        defer temp_buffer.deinit();

        // iterate over each level and pull out values
        for (parsed_level) |value| {
            const num = try std.fmt.parseInt(i32, value, 10);
            try temp_buffer.append(num);
        }

        // get sorted version of the levels for comparing
        const sorted_asc = try allocator.alloc(i32, temp_buffer.items.len);
        defer allocator.free(sorted_asc);
        const sorted_desc = try allocator.alloc(i32, temp_buffer.items.len);
        defer allocator.free(sorted_desc);
        @memcpy(sorted_asc, temp_buffer.items);
        @memcpy(sorted_desc, temp_buffer.items);
        std.mem.sort(i32, sorted_asc, {}, comptime std.sort.asc(i32));
        std.mem.sort(i32, sorted_desc, {}, comptime std.sort.desc(i32));

        var test_flag: bool = true; // flag to validate if good level or not

        // check if level is either all increasing or decreasing
        if (std.mem.eql(i32, temp_buffer.items, sorted_asc) or std.mem.eql(i32, temp_buffer.items, sorted_desc)) {
            var past_val: i32 = undefined;

            // step through each value on a level
            for (temp_buffer.items, 0..) |value, i| {
                // if we have an old value to compare to begin tests
                if (i != 0) {
                    // if differnce in values are >3 or 0 then fail level
                    if (@abs(value - past_val) > 3 or value == past_val) {
                        std.debug.print("{d} differnce out of bounds\n", .{temp_buffer.items});
                        test_flag = false;
                        break;
                    }
                }

                past_val = value;
            }
        } else {
            std.debug.print("{d} Failed sorting\n", .{temp_buffer.items});
            test_flag = false;
        }

        // if not fail conditions have been found incrment the safe level count
        if (test_flag) {
            std.debug.print("{d} Passed!!!\n", .{temp_buffer.items});
            safe_levels += 1;
        }
    }

    // Print result
    std.debug.print("result is {d}\n", .{safe_levels});
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

fn parse_data_by_line(
    allocator: std.mem.Allocator,
    input_buf: []const u8,
) ![][]const u8 {
    var levels = std.mem.tokenizeAny(u8, input_buf, "\n\r");
    var parsed_lvl = std.ArrayList([]const u8).init(allocator);

    while (levels.next()) |token| {
        const owned_token = try allocator.dupe(u8, token);
        try parsed_lvl.append(owned_token);
    }

    return parsed_lvl.items;
}
