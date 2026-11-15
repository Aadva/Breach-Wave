class_name BaseCastle
extends Node2D
## The enemy base: a round gray fort at the end of the path.

func _draw() -> void:
    var r := 38.0
    for i in range(12):
        var a := TAU * float(i) / 12.0
        draw_circle(Vector2(cos(a), sin(a)) * (r + 4.0), 6.5, Color(0.42, 0.42, 0.44))
    draw_circle(Vector2.ZERO, r, Color(0.52, 0.52, 0.54))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(0.3, 0.3, 0.32), 3.0)
    draw_circle(Vector2.ZERO, r * 0.55, Color(0.45, 0.45, 0.47))
    draw_rect(Rect2(-7, -r - 8, 14, 10), Color(0.1, 0.1, 0.1))
