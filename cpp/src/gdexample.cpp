#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>

namespace g = godot;

namespace shipper {

void CppShip::_bind_methods() {
    // Position changed
    ADD_SIGNAL(g::MethodInfo(
        "position_changed", g::PropertyInfo(g::Variant::OBJECT, "node"),
        g::PropertyInfo(g::Variant::VECTOR2, "new_pos")
    ));
    // Speed
    g::ClassDB::bind_method(g::D_METHOD("get_speed"), &CppShip::get_speed);
    g::ClassDB::bind_method(
        g::D_METHOD("set_speed", "p_speed"), &CppShip::set_speed
    );
    g::ClassDB::add_property(
        "CppShip",
        g::PropertyInfo(g::Variant::FLOAT, "speed", g::PROPERTY_HINT_RANGE, "0,2000,100"),
        "set_speed", "get_speed"
    );
}

CppShip::CppShip() {
    speed = 500.0;
}

CppShip::~CppShip() {
    // Add your cleanup here.
}

double CppShip::get_speed() const { return speed; }

void CppShip::set_speed(const double p_speed) { speed = p_speed; }

void CppShip::_process(double delta) {
    if (g::Engine::get_singleton()->is_editor_hint()) {
        return;
    }
    auto move = speed * delta;
    auto target_pos = target->get_position();
    auto center = g::Vector2(target_pos.x, 0.5 * (start.y + target_pos.y));
    auto position = sprite->get_position();
    auto offset = position - center;
    if (offset.x > 0) {
        if (position.x > start.x && time_emit < 0.1) {
            position = start;
        } else {
            // Right side, top or bottom.
            auto direction = offset.y < 0 ? -1.0 : 1.0;
            position.x += direction * move;
        }
    } else {
        // Left side.
        auto angle = std::atan2(offset.y, offset.x);
        position.x += move * std::sin(angle);
        position.y -= move * std::cos(angle);
    }
    sprite->set_position(position);
    // Track for signal.
    time_emit += delta;
    if (time_emit > 1.0) {
        emit_signal("position_changed", this, offset);
        time_emit = 0.0;
    }
}

void CppShip::_ready() {
    if (g::Engine::get_singleton()->is_editor_hint()) {
        return;
    }
    sprite = get_node<g::Node2D>(g::NodePath("Sprite"));
    start = sprite->get_position();
    target = get_node<g::Node2D>(g::NodePath("Target"));
}

}
