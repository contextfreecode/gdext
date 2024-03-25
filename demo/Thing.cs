using System;
using Godot;

public partial class Thing : Sprite2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() { }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		var velocity = Vector2.Up.Rotated(Rotation);
		Position += 400 * velocity * (float)delta;
		Rotation += Mathf.Pi * (float)delta;
	}
}
