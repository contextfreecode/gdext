use godot::prelude::*;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

#[derive(GodotClass)]
#[class(base=Node)]
struct RustShip {
    speed: f64,
    base: Base<Node>,
    sprite: Option<Gd<Node2D>>,
    state: State,
}

#[godot_api]
impl INode2D for RustShip {
    fn init(base: Base<Node>) -> Self {
        godot_print!("Hello, world!"); // Prints to the Godot console
        Self {
            speed: 400.0,
            base,
            sprite: None,
            state: State::Wait,
        }
    }

    fn physics_process(&mut self, delta: f64) {
        let sprite = self.sprite.as_mut().unwrap();
        sprite.get_position();
        // In GDScript, this would be:
        // rotation += angular_speed * delta

        // let radians = (self.angular_speed * delta) as f32;
        // self.base_mut().rotate(radians);
        // The 'rotate' method requires a f32,
        // therefore we convert 'self.angular_speed * delta' which is a f64 to a f32
    }

    fn ready(&mut self) {
        self.sprite = Some(
            self.base()
                .get_node("Sprite".into())
                .unwrap()
                .cast::<Node2D>(),
        );
    }
}

enum State {
    Wait,
    Start,
    Enter,
    Loop,
    Exit,
}
