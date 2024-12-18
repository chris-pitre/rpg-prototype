using Godot;
using System;
using System.Collections.Generic;

public partial class CityMap : Control
{
    [Export]
    public Godot.Collections.Array<Godot.Collections.Array<int>> numbers = new Godot.Collections.Array<Godot.Collections.Array<int>>();

    public override void _Ready()
    {
        base._Ready();
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        
    }
}
