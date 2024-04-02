#include "gdexample.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace g = godot;

namespace shipper {

void CppShip::_bind_methods() {
    // Attack
    g::ClassDB::bind_method(
        g::D_METHOD("attack", "ship_y", "target_x", "target_y"),
        &CppShip::attack
    );
    // Position changed
    ADD_SIGNAL(g::MethodInfo(
        "attack_finished", g::PropertyInfo(g::Variant::OBJECT, "node")
    ));
    // Speed
    g::ClassDB::bind_method(g::D_METHOD("get_speed"), &CppShip::get_speed);
    g::ClassDB::bind_method(
        g::D_METHOD("set_speed", "p_speed"), &CppShip::set_speed
    );
    g::ClassDB::add_property(
        "CppShip",
        g::PropertyInfo(
            g::Variant::FLOAT, "speed", g::PROPERTY_HINT_RANGE, "0,2000,100"
        ),
        "set_speed", "get_speed"
    );
}

CppShip::CppShip() {}

CppShip::~CppShip() {
    // Add your cleanup here.
}

void CppShip::attack(double ship_y, double target_x, double target_y) {
    if (state != State::Wait) return;
    state = State::Enter;
    // TODO Interpret args.
}

double CppShip::get_speed() const { return speed; }

void CppShip::set_speed(const double p_speed) { speed = p_speed; }

void CppShip::_process(double delta) {
    if (g::Engine::get_singleton()->is_editor_hint()) {
        return;
    }
    auto position = sprite->get_position();
    auto target = this->target->get_position();
    if (state == State::Wait) {
        start = position;
    }
    auto old_state = state;
    state = ([this, position, target]() {
        switch (state) {
            case State::Enter:
                return position.x < target.x ? State::Turn : state;
            case State::Turn:
                return position.x > target.x ? State::Exit : state;
            case State::Exit:
                return position.x > start.x ? State::Wait : state;
            default:
                return state;
        }
    })();
    position += speed * delta * ([this, position, target]() {
        switch (state) {
            case State::Enter:
                return g::Vector2(-1, 0);
            case State::Turn: {
                auto center = g::Vector2(target.x, 0.5 * (start.y + target.y));
                auto offset = position - center;
                auto angle = std::atan2(offset.y, offset.x);
                return g::Vector2(std::sin(angle), -std::cos(angle));
            }
            case State::Exit:
                return g::Vector2(1, 0);
            default:
                return g::Vector2(0, 0);
        }
    })();
    if (state == State::Wait) {
        if (old_state != state) {
            emit_signal("attack_finished", this);
        }
        position = start;
    }
    sprite->set_position(position);
}

void CppShip::_ready() {
    if (g::Engine::get_singleton()->is_editor_hint()) {
        return;
    }
    sprite = get_node<g::Node2D>(g::NodePath("Sprite"));
    start = sprite->get_position();
    target = get_node<g::Node2D>(g::NodePath("Target"));
}

} // namespace shipper
