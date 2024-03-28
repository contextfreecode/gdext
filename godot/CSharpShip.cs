using System;
using Godot;

public partial class CSharpShip : Node
{
	public float Speed = 500;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		sprite = GetNode<Node2D>("Sprite");
		target = GetNode<Node2D>("Target");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		var move = Speed * (float)delta;
		switch (state)
		{
			case State.Wait:
			{
				// TODO Transition only on request.
				start = sprite.Position;
				state = State.Top;
				break;
			}
			case State.Top:
			{
				sprite.Position += new Vector2(move, 0);
				if (sprite.Position.X > target.Position.X)
				{
					state = State.Right;
				}
				break;
			}
			case State.Right:
			{
				sprite.Position += new Vector2(0, move);
				if (sprite.Position.Y > target.Position.Y)
				{
					state = State.Bottom;
				}
				break;
			}
			case State.Bottom:
			{
				sprite.Position += new Vector2(-move, 0);
				if (sprite.Position.X < target.Position.X / 2)
				{
					state = State.Left;
				}
				break;
			}
			case State.Left:
			{
				sprite.Position += new Vector2(0, -move);
				if (sprite.Position.Y < -200)
				{
					sprite.Position = start;
					state = State.Wait;
				}
				break;
			}
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
