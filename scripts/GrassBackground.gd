class_name GrassBackground
extends Node2D
## Simple procedural grass background (fixed seed so it never changes).

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1152, 648), Color(0.36, 0.63, 0.27))
    var rng := RandomNumberGenerator.new()
    rng.seed = 12345
    for i in range(700):
        var p := Vector2(rng.randf_range(0.0, 1152.0), rng.randf_range(0.0, 648.0))
        var s := rng.randf_range(2.0, 4.0)
        draw_circle(p, s, Color(0.31, 0.56, 0.23, 0.55))
        draw_circle(p + Vector2(-1, -1), s * 0.5, Color(0.45, 0.72, 0.35, 0.5))
