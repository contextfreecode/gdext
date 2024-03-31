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

pub fn attack(self: *Self, ship_y: f64, target_x: f64, target_y: f64) void {
    _ = self;
    _ = ship_y;
    _ = target_x;
    _ = target_y;
}

pub fn _physics_process(self: *Self, delta: f64) void {
    if (Godot.Engine.getSingleton().is_editor_hint()) return;
    var position = self.sprite.get_position();
    if (self.state == .wait) self.start = position;
    const target = self.target.get_position();
    const exit = target[0] / 2;
    const end = -200;
    const old_state = self.state;
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
    if (self.state == .wait) {
        // _ = old_state;
        if (self.state != old_state) {
            _ = self.emit_signal_self("finished");
        }
        position = self.start;
    }
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

var finished_signal: Godot.StringName = undefined;

pub fn register() void {
    Godot.registerClass(Self);
    Godot.registerMethod(Self, "attack");
    finished_signal = Godot.StringName.initFromString(
        Godot.String.initFromUtf8Chars("finished"),
    );
    // TODO Deinit these things.
    object_str = Godot.String.initFromUtf8Chars("Object");
    emit_signal_str = Godot.String.initFromUtf8Chars("emit_signal");
    gde_method_bind = Godot.classdbGetMethodBind(
        &object_str,
        &emit_signal_str,
        // Hash copied from object.cpp Object::emit_signal_internal
        4047867050,
    );
}

const GDE = Godot.GDE;
var object_str: Godot.String = undefined;
var emit_signal_str: Godot.String = undefined;
var gde_method_bind: GDE.GDExtensionMethodBindPtr = undefined;

fn emit(self: *Self, signal: Godot.StringName) void {
    var ret: Godot.Variant = undefined;
    var err: GDE.GDExtensionCallError = undefined;
    const name_arg = Godot.Variant.init(*Godot.StringName, @constCast(&signal));
    const self_arg = Godot.Variant.init(*Self, self);
    const args = [_]*const Godot.Variant{ &name_arg, &self_arg };
    Godot.objectMethodBindCall(
        gde_method_bind,
        self,
        @ptrCast(&args),
        args.len,
        &ret,
        &err,
    );
}

const GlobalEnums = Godot.GlobalEnums;
const Object = Godot.Object;
const String = Godot.String;
const StringName = Godot.StringName;

// Modified from: Object.zig: pub fn emit_signal(self: anytype, signal_: anytype) GlobalEnums.Error {
pub fn emit_signal_self(self: *Self, signal_: anytype) GlobalEnums.Error {
    var result: GlobalEnums.Error = @import("std").mem.zeroes(GlobalEnums.Error);
    var ret: Godot.Variant = undefined;
    var args: [2]GDE.GDExtensionConstTypePtr = undefined;
    if (@TypeOf(signal_) == StringName or @TypeOf(signal_) == String) {
        args[0] = @ptrCast(&signal_);
    } else {
        args[0] = @ptrCast(&StringName.initFromLatin1Chars(@as([*c]const u8, &signal_[0])));
    }
    args[1] = @ptrCast(self.godot_object);
    const Binding = struct {
        pub var method: GDE.GDExtensionMethodBindPtr = null;
    };
    if (Binding.method == null) {
        const func_name = StringName.initFromLatin1Chars("emit_signal");
        Binding.method = Godot.classdbGetMethodBind(@ptrCast(Godot.getClassName(Object)), @ptrCast(&func_name), 4047867050);
    }
    Godot.objectMethodBindCall(Binding.method.?, @ptrCast(self.godot_object), &args[0], args.len, &ret, @ptrCast(&result));
    return result;
}
