const std = @import("std");

fn puzzle1(input_file: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(input_file, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());

    var list_1 = std.ArrayList(i32).init(allocator);
    defer list_1.deinit();
    var list_2 = std.ArrayList(i32).init(allocator);
    defer list_2.deinit();

    var token = std.mem.tokenizeAny(u8, content, " \n");
    while (token.peek() != null) {
        list_1.append(try std.fmt.parseInt(i32, try token.next().?, 10));
        list_2.append(try std.fmt.parseInt(i32, try token.next().?, 10));
    }

    const sorted_list_1 = std.sort.asc(i32)

}
