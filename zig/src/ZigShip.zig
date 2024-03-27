const Godot = @import("Godot");

const Self = @This();

pub usingnamespace Godot.Sprite2D;
godot_object: *Godot.Sprite2D,

pub fn _physics_process(self: *Self, delta: f64) void {
    if (Godot.Engine.getSingleton().is_editor_hint()) return;
    self.rotate(delta);
}
