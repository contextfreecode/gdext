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

class CppShip : public godot::Node2D {
    GDCLASS(CppShip, godot::Node2D)

  private:
    double speed = 500.0;

    godot::Node2D* sprite;
    godot::Vector2 start;
    State state = State::Wait;
    godot::Node2D* target;

  protected:
    static void _bind_methods();

  public:
    CppShip();
    ~CppShip();

    void attack(double ship_y, double target_x, double target_y);
    double get_speed() const;
    void set_speed(const double p_speed);

    void _process(double delta) override;
    void _ready() override;
};

} // namespace shipper

#endif
