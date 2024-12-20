const std = @import("std");
const INPUT_BUFFER_SIZE = 1048576;

pub fn main() !void {
    var final_sum: i64 = 0;
    const input_path = "input.txt";
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
        if (try equation.solvable(allocator)) {
            final_sum += equation.answer;
        }
    }

    std.debug.print("final sum is {d}\n", .{final_sum});
}

const Node = struct {
    result: i64 = undefined,
    left: ?*Node = undefined,
    right: ?*Node = undefined,

    pub fn init(allocator: std.mem.Allocator, value: i64) *Node {
        const newNode = allocator.create(Node) catch unreachable;
        newNode.* = Node{
            .result = value,
            .left = null,
            .right = null,
        };
        return newNode;
    }

    pub fn createTree(allocator: std.mem.Allocator, operands: []i64, index: usize, current_node: ?*Node) ?*Node {
        if (index >= operands.len) return null;

        var root = current_node;

        if (current_node == null) {
            root = Node.init(allocator, operands[index]);
        }

        if (index + 1 < operands.len) {
            const leftValue = root.?.result + operands[index + 1];
            const rightValue = root.?.result * operands[index + 1];

            root.?.left = Node.createTree(allocator, operands, index + 1, Node.init(allocator, leftValue));
            root.?.right = Node.createTree(allocator, operands, index + 1, Node.init(allocator, rightValue));

            if (root.?.left != null) root.?.left.?.result = leftValue;
            if (root.?.right != null) root.?.right.?.result = rightValue;
        }

        return root;
    }

    pub fn findLeafNodes(self: *Node, results: *std.ArrayList(i64)) !void {
        if (self.left == null or self.right == null) {
            try results.append(self.result);
            return;
        }

        if (self.left != null) {
            try self.left.?.findLeafNodes(results);
        }
        if (self.right != null) {
            try self.right.?.findLeafNodes(results);
        }
    }

    pub fn traverseInOrder(self: *Node) void {
        if (self.left != null) {
            self.left.?.traverseInOrder();
        }
        std.debug.print("{d} ", .{self.result});
        if (self.right != null) {
            self.right.?.traverseInOrder();
        }
    }
};

const BinaryTree = struct {
    root: ?*Node,

    pub fn init(allocator: std.mem.Allocator, operands: []i64) BinaryTree {
        return BinaryTree{ .root = Node.createTree(allocator, operands, 0, null) };
    }

    pub fn traverseInOrder(self: *BinaryTree) void {
        if (self.root != null) {
            self.root.?.traverseInOrder();
        }
    }

    pub fn getLeafNodes(self: *BinaryTree, results: *std.ArrayList(i64)) !void {
        if (self.root != null) {
            try self.root.?.findLeafNodes(results);
        }
    }
};

const Equation = struct {
    equation_line_string: [100]u8 = undefined,
    answer: i64 = undefined,
    operands: std.ArrayList(i64) = undefined,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, line: []const u8) !Self {
        var self: Self = .{};

        var token = std.mem.tokenizeAny(u8, line, " :\n\r");
        if (token.peek() != null) {
            self.answer = try std.fmt.parseInt(i64, token.next().?, 10);
        }

        self.operands = std.ArrayList(i64).init(allocator);
        while (token.peek() != null) {
            try self.operands.append(try std.fmt.parseInt(i64, token.next().?, 10));
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

    pub fn solvable(self: *Self, allocator: std.mem.Allocator) !bool {
        var tree = BinaryTree.init(allocator, self.operands.items);
        var final_results = std.ArrayList(i64).init(allocator);
        defer final_results.deinit();
        try tree.getLeafNodes(&final_results);
        for (final_results.items) |result| {
            if (result == self.answer) return true;
        }
        return false;
    }
};
