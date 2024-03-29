const Godot = @import("Godot");
const Vector2 = Godot.Vector2;

const Self = @This();

pub usingnamespace Godot.Node;
godot_object: *Godot.Node,

speed: f32 = 500,

sprite: *Godot.Node2D = undefined,
state: State = .wait,
start: Vector2 = @splat(0),
target: *Godot.Node2D = undefined,

pub fn _physics_process(self: *Self, delta: f64) void {
    if (Godot.Engine.getSingleton().is_editor_hint()) return;
    var position = self.sprite.get_position();
    if (self.state == .wait) self.start = position;
    const target = self.target.get_position();
    const exit = target[0] / 2;
    const end = -200;
    self.state = switch (self.state) {
        .wait => .enter,
        .enter => if (position[0] < target[0]) .zag else self.state,
        .zag => if (position[0] < exit) .exit else self.state,
        .exit => if (position[0] < end) .wait else self.state,
    };
    const distance: Vector2 = @splat(@as(f32, @floatCast(delta)) * self.speed);
    position += distance * switch (self.state) {
        .wait => Vector2{ 0, 0 },
        .enter => Godot.normalized(target - self.start),
        .zag => Godot.normalized(Vector2{
            exit - target[0],
            self.start[1] - target[1],
        }),
        .exit => Godot.normalized(Vector2{
            end - exit,
            target[1] - self.start[1],
        }),
    };
    if (self.state == .wait) position = self.start;
    self.sprite.set_position(position);
}

pub fn _ready(self: *Self) void {
    if (Godot.Engine.getSingleton().is_editor_hint()) return;
    // Sprite
    var sprite_path = Godot.NodePath.initFromString("Sprite");
    defer sprite_path.deinit();
    self.sprite = @ptrCast(self.get_node(sprite_path));
    // Target
    var target_path = Godot.NodePath.initFromString("Target");
    defer target_path.deinit();
    self.target = @ptrCast(self.get_node(target_path));
}

const State = enum {
    wait,
    enter,
    zag,
    exit,
};
