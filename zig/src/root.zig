const godot = @import("godot");
const std = @import("std");
const testing = std.testing;

const GDE = godot.GDE;

pub export fn my_extension_init(
    p_get_proc_address: GDE.GDExtensionInterfaceGetProcAddress,
    p_library: GDE.GDExtensionClassLibraryPtr,
    r_initialization: [*c]GDE.GDExtensionInitialization,
) callconv(.C) GDE.GDExtensionBool {
    _ = p_get_proc_address;
    _ = p_library;
    _ = r_initialization;
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
