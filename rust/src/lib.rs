use godot::prelude::*;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

#[derive(GodotClass)]
#[class(base=Node2D)]
struct RustShip {
    #[export(range=(0.0, 2000.0, 100.0))]
    speed: f32,
    base: Base<Node2D>,
    sprite: Option<Gd<Node2D>>,
    start: Vector2,
    state: State,
    target: Option<Gd<Node2D>>,
}

#[godot_api]
impl RustShip {
    #[func]
    fn attack(&mut self, ship_y: f64, target_x: f64, target_y: f64) {
        if self.state != State::Wait {
            return;
        }
        self.state = State::Enter;
        // TODO Interpret args.
    }

    #[signal]
    fn attack_finished(node: Gd<Node>);
}

#[godot_api]
impl INode2D for RustShip {
    fn init(base: Base<Node2D>) -> Self {
        // godot_print!("rust init");
        Self {
            speed: 500f32,
            base,
            sprite: None,
            start: Vector2::ZERO,
            state: State::Wait,
            target: None,
        }
    }

    fn physics_process(&mut self, delta: f64) {
        let view_rect = self.base().get_viewport().unwrap().get_visible_rect();
        let sprite = self.sprite.as_mut().unwrap();
        let target = self.target.as_mut().unwrap().get_position();
        let position = sprite.get_position();
        let old_state = self.state;
        if self.state == State::Wait {
            self.start = position;
        }
        self.state = match self.state {
            State::Enter if position.x > target.x => State::Up,
            State::Up if position.x < target.x => State::Down,
            State::Down if position.x > target.x => State::Exit,
            State::Exit if position.x > view_rect.size.x + 200f32 => State::Wait,
            _ => self.state,
        };
        let distance = self.speed * delta as f32;
        let position = position
            + distance
                * match self.state {
                    State::Wait => Vector2::ZERO,
                    State::Enter => Vector2::RIGHT,
                    State::Up | State::Down => {
                        let mid_y = (self.start.y + target.y) / 2f32;
                        let center = Vector2::new(target.x, mid_y);
                        let angle = (position - center).angle();
                        Vector2::new(angle.sin(), -angle.cos())
                    }
                    State::Exit => Vector2::RIGHT,
                };
        let position = match () {
            _ if self.state == State::Wait => self.start,
            _ => position,
        };
        sprite.set_position(position);
        if self.state == State::Wait && self.state != old_state {
            let other_self = self.base().clone();
            self.base_mut()
                .emit_signal("attack_finished".into(), &[Variant::from(other_self)]);
        }
    }

    fn ready(&mut self) {
        // godot_print!("rust ready");
        self.sprite = Some(
            self.base()
                .get_node("Sprite".into())
                .unwrap()
                .cast::<Node2D>(),
        );
        self.target = Some(
            self.base()
                .get_node("Target".into())
                .unwrap()
                .cast::<Node2D>(),
        );
    }
}

#[derive(Clone, Copy, PartialEq)]
enum State {
    Wait,
    Enter,
    Up,
    Down,
    Exit,
}
