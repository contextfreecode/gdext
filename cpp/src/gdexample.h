#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace shipper {

class CppShip : public godot::Node {
    GDCLASS(CppShip, godot::Node)

  private:
    double speed;

    godot::Node2D* sprite;
    godot::Vector2 start;
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

} // namespace godot

#endif
