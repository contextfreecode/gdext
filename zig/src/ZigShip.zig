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
    if (self.state != State.wait) return;
    self.state = State.enter;
    // TODO Interpret args.
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
        .wait => self.state,
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
            _ = self.emit_signal_self(attack_finished_signal);
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
    _ = self.emit_signal_self(attack_finished_signal);
}

const State = enum {
    wait,
    enter,
    zag,
    exit,
};

var attack_finished_signal: Godot.StringName = undefined;

// pub fn add_user_signal(
//     self: anytype,
//     signal_: anytype,
//     arguments_: Array,
// ) void {
//     var args: [2]GDE.GDExtensionConstTypePtr = undefined;
//     if (@TypeOf(signal_) == StringName or @TypeOf(signal_) == String) {
//         args[0] = @ptrCast(&signal_);
//     } else {
//         args[0] = @ptrCast(
//             &String.initFromLatin1Chars(@as([*c]const u8, &signal_[0])),
//         );
//     }
//     args[1] = @ptrCast(&arguments_);
//     const Binding = struct {
//         pub var method: GDE.GDExtensionMethodBindPtr = null;
//     };
//     if (Binding.method == null) {
//         const func_name = StringName.initFromLatin1Chars("add_user_signal");
//         Binding.method = Godot.classdbGetMethodBind(
//             @ptrCast(Godot.getClassName(Object)),
//             @ptrCast(&func_name),
//             85656714,
//         );
//     }
//     Godot.objectMethodBindPtrcall(
//         Binding.method.?,
//         @ptrCast(self.godot_object),
//         &args[0],
//         null,
//     );
// }

// void Object::add_user_signal(const MethodInfo &p_signal) {
// 	ERR_FAIL_COND_MSG(p_signal.name.is_empty(), "Signal name cannot be empty.");
// 	ERR_FAIL_COND_MSG(ClassDB::has_signal(get_class_name(), p_signal.name), "User signal's name conflicts with a built-in signal of '" + get_class_name() + "'.");
// 	ERR_FAIL_COND_MSG(signal_map.has(p_signal.name), "Trying to add already existing signal '" + p_signal.name + "'.");
// 	SignalData s;
// 	s.user = p_signal;
// 	signal_map[p_signal.name] = s;
// }

// ADD_SIGNAL(
//     g::MethodInfo("attack_finished", g::PropertyInfo(g::Variant::OBJECT, "node"))
// );

// void ClassDB::add_signal(const StringName &p_class, const MethodInfo &p_signal) {
// 	std::unordered_map<StringName, ClassInfo>::iterator type_it = classes.find(p_class);
// 	ERR_FAIL_COND_MSG(type_it == classes.end(), String("Class '{0}' doesn't exist.").format(Array::make(p_class)));
// 	ClassInfo &cl = type_it->second;
// 	// Check if this signal is already register
// 	ClassInfo *check = &cl;
// 	while (check) {
// 		ERR_FAIL_COND_MSG(check->signal_names.find(p_signal.name) != check->signal_names.end(), String("Class '{0}' already has signal '{1}'.").format(Array::make(p_class, p_signal.name)));
// 		check = check->parent_ptr;
// 	}
// 	// register our signal in our plugin
// 	cl.signal_names.insert(p_signal.name);
// 	// register our signal in godot
// 	std::vector<GDExtensionPropertyInfo> parameters;
// 	parameters.reserve(p_signal.arguments.size());
// 	for (const PropertyInfo &par : p_signal.arguments) {
// 		parameters.push_back(GDExtensionPropertyInfo{
// 				static_cast<GDExtensionVariantType>(par.type), // GDExtensionVariantType type;
// 				par.name._native_ptr(), // GDExtensionStringNamePtr name;
// 				par.class_name._native_ptr(), // GDExtensionStringNamePtr class_name;
// 				par.hint, // NONE //uint32_t hint;
// 				par.hint_string._native_ptr(), // GDExtensionStringPtr hint_string;
// 				par.usage, // DEFAULT //uint32_t usage;
// 		});
// 	}
// 	internal::gdextension_interface_classdb_register_extension_class_signal(internal::library, cl.name._native_ptr(), p_signal.name._native_ptr(), parameters.data(), parameters.size());
// }

// void GDExtension::_register_extension_class_signal(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringNamePtr p_signal_name, const GDExtensionPropertyInfo *p_argument_info, GDExtensionInt p_argument_count) {
// 	GDExtension *self = reinterpret_cast<GDExtension *>(p_library);
// 	StringName class_name = *reinterpret_cast<const StringName *>(p_class_name);
// 	StringName signal_name = *reinterpret_cast<const StringName *>(p_signal_name);
// 	ERR_FAIL_COND_MSG(!self->extension_classes.has(class_name), "Attempt to register extension class signal '" + signal_name + "' for unexisting class '" + class_name + "'.");
// #ifdef TOOLS_ENABLED
// 	// If the extension is still marked as reloading, that means it failed to register again.
// 	Extension *extension = &self->extension_classes[class_name];
// 	if (extension->is_reloading) {
// 		return;
// 	}
// #endif
// 	MethodInfo s;
// 	s.name = signal_name;
// 	for (int i = 0; i < p_argument_count; i++) {
// 		PropertyInfo arg(p_argument_info[i]);
// 		s.arguments.push_back(arg);
// 	}
// 	ClassDB::add_signal(class_name, s);
// }

// MethodBinder.arg_properties[0] = GDE.GDExtensionPropertyInfo{
//     .type = @intCast(Variant.getVariantType(MethodBinder.ReturnType.?)),
//     .name = @ptrCast(@constCast(&StringName.init())),
//     .class_name = @ptrCast(@constCast(&StringName.init())),
//     .hint = GD.GlobalEnums.PROPERTY_HINT_NONE,
//     .hint_string = @ptrCast(@constCast(&String.init())),
//     .usage = GD.GlobalEnums.PROPERTY_USAGE_NONE,
// };

// pub const GDExtensionInterfaceClassdbRegisterExtensionClassSignal = ?*const fn (
//     GDExtensionClassLibraryPtr,
//     GDExtensionConstStringNamePtr,
//     GDExtensionConstStringNamePtr,
//     [*c]const GDExtensionPropertyInfo,
//     GDExtensionInt,
// ) callconv(.C) void;

pub fn register() void {
    Godot.registerClass(Self);
    Godot.registerMethod(Self, "attack");
    attack_finished_signal = Godot.StringName.initFromString(
        Godot.String.initFromUtf8Chars("attack_finished"),
    );
    const node_name = Godot.StringName.initFromString(
        Godot.String.initFromUtf8Chars("node"),
    );
    const attack_finished_property = GDE.GDExtensionPropertyInfo{
        .type = @intCast(GDE.GDEXTENSION_VARIANT_TYPE_OBJECT),
        .name = @ptrCast(@constCast(&node_name)),
        .class_name = Godot.getClassName(Godot.Node),
        .hint = Godot.GlobalEnums.PROPERTY_HINT_NONE,
        .hint_string = @ptrCast(@constCast(&String.init())),
        .usage = Godot.GlobalEnums.PROPERTY_USAGE_NONE,
    };
    Godot.classdbRegisterExtensionClassSignal(
        Godot.p_library,
        Godot.getClassName(Self),
        &attack_finished_signal,
        &attack_finished_property,
        1,
    );
    // classdbRegisterExtensionClassSignal
    // TODO Deinit these things.
    // object_str = Godot.String.initFromUtf8Chars("Object");
    const emit_signal_str = Godot.StringName.initFromString(
        Godot.String.initFromUtf8Chars("emit_signal"),
    );
    emit_signal_method = Godot.classdbGetMethodBind(
        Godot.getClassName(Object),
        &emit_signal_str,
        // Hash copied from object.cpp Object::emit_signal_internal
        4047867050,
    );
}

const GDE = Godot.GDE;
// var object_str: Godot.String = undefined;
// var emit_signal_str: Godot.StringName = undefined;
var emit_signal_method: GDE.GDExtensionMethodBindPtr = undefined;

fn emit(self: *Self, signal: Godot.StringName) void {
    var ret: Godot.Variant = undefined;
    var err: GDE.GDExtensionCallError = undefined;
    const name_arg = Godot.Variant.init(*Godot.StringName, @constCast(&signal));
    const self_arg = Godot.Variant.init(*Self, @ptrCast(self.godot_object));
    const args = [_]*const Godot.Variant{ &name_arg, &self_arg };
    Godot.objectMethodBindCall(
        emit_signal_method,
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

// pub fn emit_signal(self: anytype, signal_: anytype) GlobalEnums.Error {
//     var result: GlobalEnums.Error = @import("std").mem.zeroes(GlobalEnums.Error);
//     var args: [1]GDE.GDExtensionConstTypePtr = undefined;
//     if (@TypeOf(signal_) == StringName or @TypeOf(signal_) == String) {
//         args[0] = @ptrCast(&signal_);
//     } else {
//         args[0] = @ptrCast(&StringName.initFromLatin1Chars(@as([*c]const u8, &signal_[0])));
//     }
//     const Binding = struct {
//         pub var method: GDE.GDExtensionMethodBindPtr = null;
//     };
//     if (Binding.method == null) {
//         const func_name = StringName.initFromLatin1Chars("emit_signal");
//         Binding.method = Godot.classdbGetMethodBind(
//             @ptrCast(Godot.getClassName(Object)),
//             @ptrCast(&func_name),
//             4047867050,
//         );
//     }
//     Godot.objectMethodBindPtrcall(
//         Binding.method.?,
//         @ptrCast(self.godot_object),
//         &args[0],
//         @ptrCast(&result),
//     );
//     return result;
// }

// Error Object::_emit_signal(const Variant **p_args, int p_argcount, Callable::CallError &r_error) {
// 	if (unlikely(p_argcount < 1)) {
// 		r_error.error = Callable::CallError::CALL_ERROR_TOO_FEW_ARGUMENTS;
// 		r_error.expected = 1;
// 		ERR_FAIL_V(Error::ERR_INVALID_PARAMETER);
// 	}
// 	if (unlikely(p_args[0]->get_type() != Variant::STRING_NAME && p_args[0]->get_type() != Variant::STRING)) {
// 		r_error.error = Callable::CallError::CALL_ERROR_INVALID_ARGUMENT;
// 		r_error.argument = 0;
// 		r_error.expected = Variant::STRING_NAME;
// 		ERR_FAIL_V(Error::ERR_INVALID_PARAMETER);
// 	}
// 	r_error.error = Callable::CallError::CALL_OK;
// 	StringName signal = *p_args[0];
// 	const Variant **args = nullptr;
// 	int argc = p_argcount - 1;
// 	if (argc) {
// 		args = &p_args[1];
// 	}
// 	return emit_signalp(signal, args, argc);
// }

// virtual void validated_call(Object *p_object, const Variant **p_args, Variant *r_ret) const override {
//     ERR_FAIL_MSG("Validated call can't be used with vararg methods. This is a bug.");
// }

// virtual void ptrcall(Object *p_object, const void **p_args, void *r_ret) const override {
//     ERR_FAIL_MSG("ptrcall can't be used with vararg methods. This is a bug.");
// }

// typedef void (*GDExtensionInterfaceObjectMethodBindCall)(GDExtensionMethodBindPtr p_method_bind, GDExtensionObjectPtr p_instance, const GDExtensionConstVariantPtr *p_args, GDExtensionInt p_arg_count, GDExtensionUninitializedVariantPtr r_ret, GDExtensionCallError *r_error);

// Variant::Variant(const StringName &v) {
// 	from_type_constructor[STRING_NAME](_native_ptr(), v._native_ptr());
// }

// Variant::Variant(const Object *v) {
// 	if (v) {
// 		from_type_constructor[OBJECT](_native_ptr(), const_cast<GodotObject **>(&v->_owner));
// 	} else {
// 		GodotObject *nullobject = nullptr;
// 		from_type_constructor[OBJECT](_native_ptr(), &nullobject);
// 	}
// }

// Modified from: Object.zig: pub fn emit_signal(self: anytype, signal_: anytype) GlobalEnums.Error {
pub fn emit_signal_self(self: *Self, signal_: anytype) GlobalEnums.Error {
    var result: GlobalEnums.Error = @import("std").mem.zeroes(GlobalEnums.Error);
    var ret: Godot.Variant = undefined;
    var signal_name: StringName = undefined;
    if (@TypeOf(signal_) == StringName) {
        signal_name = signal_;
    } else if (@TypeOf(signal_) == String) {
        signal_name = StringName.initFromString(signal_);
    } else {
        signal_name = StringName.initFromLatin1Chars(@as([*c]const u8, &signal_[0]));
    }
    const name_arg = Godot.Variant.init(*Godot.StringName, &signal_name);
    const self_arg = Godot.Variant.init(*Godot.Node, self.godot_object);
    const args = [_]GDE.GDExtensionConstVariantPtr{ &name_arg, &self_arg };
    Godot.objectMethodBindCall(
        emit_signal_method,
        @ptrCast(self.godot_object),
        &args,
        args.len,
        &ret,
        @ptrCast(&result),
    );
    return result;
}
