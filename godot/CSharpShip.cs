using System;
using Godot;

public partial class CSharpShip : Node
{
    [Export(PropertyHint.Range, "0,2000,100")]
    public float Speed = 500;

    [Signal]
    public delegate void attack_finishedEventHandler(Node node);

    public void attack(double ship_y, double target_x, double target_y)
    {
        if (state != State.Wait) return;
        state = State.Top;
        // TODO Interpret args.
    }

    public override void _Ready()
    {
        sprite = GetNode<Node2D>("Sprite");
        target = GetNode<Node2D>("Target");
    }

    public override void _Process(double delta)
    {
        var move = Speed * (float)delta;
        if (state == State.Wait)
        {
            start = sprite.Position;
        }
        var oldState = state;
        state = state switch
        {
            State.Top when sprite.Position.X > target.Position.X => State.Right,
            State.Right when sprite.Position.Y > target.Position.Y => State.Bottom,
            State.Bottom when sprite.Position.X < target.Position.X / 2 => State.Left,
            State.Left when sprite.Position.Y < -200 => State.Wait,
            _ => state,
        };
        sprite.Position +=
            move
            * state switch
            {
                State.Wait => Vector2.Zero,
                State.Top => Vector2.Right,
                State.Right => Vector2.Down,
                State.Bottom => Vector2.Left,
                State.Left => Vector2.Up,
            };
        if (state == State.Wait)
        {
            if (oldState != state)
            {
                EmitSignal(SignalName.attack_finished, this);
            }
            sprite.Position = start;
        }
    }

    private Node2D sprite;
    private Vector2 start;
    private State state = State.Wait;
    private Node2D target;

    private enum State
    {
        Wait,
        Top,
        Right,
        Bottom,
        Left,
    }
}
