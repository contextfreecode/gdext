#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace shipper {

enum class State {
    Wait,
    Enter,
    Turn,
    Exit,
};

class CppShip : public godot::Node {
    GDCLASS(CppShip, godot::Node)

  private:
    double speed = 500.0;

    godot::Node2D* sprite;
    godot::Vector2 start;
    State state = State::Wait;
    godot::Node2D* target;
    double time_emit;

  protected:
    static void _bind_methods();

  public:
    CppShip();
    ~CppShip();

    double get_speed() const;
    void set_speed(const double p_speed);

    void _process(double delta) override;
    void _ready() override;
};

} // namespace shipper

#endif
