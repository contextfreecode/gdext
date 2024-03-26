#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

void CppShip::_bind_methods() {
    // Amplitude
    ClassDB::bind_method(D_METHOD("get_amplitude"), &CppShip::get_amplitude);
    ClassDB::bind_method(
        D_METHOD("set_amplitude", "p_amplitude"), &CppShip::set_amplitude
    );
    ClassDB::add_property(
        "CppShip", PropertyInfo(Variant::FLOAT, "amplitude"), "set_amplitude",
        "get_amplitude"
    );
    // Position changed
    ADD_SIGNAL(MethodInfo(
        "position_changed", PropertyInfo(Variant::OBJECT, "node"),
        PropertyInfo(Variant::VECTOR2, "new_pos")
    ));
    // Speed
    ClassDB::bind_method(D_METHOD("get_speed"), &CppShip::get_speed);
    ClassDB::bind_method(
        D_METHOD("set_speed", "p_speed"), &CppShip::set_speed
    );
    ClassDB::add_property(
        "CppShip",
        PropertyInfo(Variant::FLOAT, "speed", PROPERTY_HINT_RANGE, "0,20,0.01"),
        "set_speed", "get_speed"
    );
}

CppShip::CppShip() {
    amplitude = 10.0;
    speed = 1.0;
    time_passed = 0.0;
}

CppShip::~CppShip() {
    // Add your cleanup here.
}

void CppShip::_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) {
        return;
    }
    time_passed += speed * delta;
    Vector2 new_position = Vector2(
        amplitude + (amplitude * sin(time_passed * 2.0)),
        amplitude + (amplitude * cos(time_passed * 1.5))
    );
    set_position(new_position);
    // Track for signal.
    time_emit += delta;
    if (time_emit > 1.0) {
        emit_signal("position_changed", this, new_position);
        time_emit = 0.0;
    }
}

double CppShip::get_amplitude() const { return amplitude; }

void CppShip::set_amplitude(const double p_amplitude) {
    amplitude = p_amplitude;
}

double CppShip::get_speed() const { return speed; }

void CppShip::set_speed(const double p_speed) { speed = p_speed; }
