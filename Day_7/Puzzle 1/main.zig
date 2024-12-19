const std = @import("std");
const INPUT_BUFFER_SIZE = 1048576;

pub fn main() !void {
    var final_sum: i32 = 0;
    const input_path = "test_input.txt";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());
    var line = std.mem.tokenizeAny(u8, content, "\n");
    while (line.peek() != null) {
        var equation: Equation = try .init(allocator, line.next().?);
        defer equation.deinit();

        equation.printEquation();
        if (equation.solvable()) {
            final_sum += equation.answer;
        }
    }

    std.debug.print("final sum is {d}\n", .{final_sum});
}

const Equation = struct {
    equation_line_string: [100]u8 = undefined,
    answer: i32 = undefined,
    operands: std.ArrayList(i32) = undefined,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, line: []const u8) !Self {
        var self: Self = .{};

        var token = std.mem.tokenizeAny(u8, line, " :\n\r");
        if (token.peek() != null) {
            self.answer = try std.fmt.parseInt(i32, token.next().?, 10);
        }

        self.operands = std.ArrayList(i32).init(allocator);
        while (token.peek() != null) {
            try self.operands.append(try std.fmt.parseInt(i32, token.next().?, 10));
        }
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.operands.deinit();
    }

    pub fn printEquation(self: *Self) void {
        std.debug.print("equation is {d}:", .{self.answer});
        for (self.operands.items) |operand| {
            std.debug.print(" {d}", .{operand});
        }
        std.debug.print("\n", .{});
    }

    pub fn solvable(self: *Self) bool {
        var temp_sum: i32 = 1;
        for (self.operands.items) |operand| {
            temp_sum *= operand;
        }
        if (temp_sum < self.answer) return false else if (temp_sum == self.answer) return true;

        temp_sum = 0;
        for (self.operands.items) |operand| {
            temp_sum += operand;
        }
        if (temp_sum > self.answer) return false else if (temp_sum == self.answer) return true;

        std.debug.print("answer possible...\n", .{});
        return true;
    }
};
