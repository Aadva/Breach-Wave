class_name SoulIcon
extends Control
## Teal teardrop "soul" icon used next to the currency counter.

func _draw() -> void:
    var col := Color(0.1, 0.72, 0.68)
    var dark := Color(0.04, 0.2, 0.2)
    var r := size.x * 0.36
    var ctr := Vector2(size.x * 0.5, size.y * 0.62)
    var tip := Vector2(ctr.x + r * 0.2, size.y * 0.02)
    draw_colored_polygon(PackedVector2Array([
        ctr + Vector2(-r * 0.92, -r * 0.4), tip, ctr + Vector2(r * 0.92, -r * 0.4)]), col)
    draw_circle(ctr, r, col)
    draw_circle(ctr + Vector2(-r * 0.4, -r * 0.05), r * 0.14, dark)
    draw_circle(ctr + Vector2(r * 0.4, -r * 0.05), r * 0.14, dark)
    draw_arc(ctr + Vector2(0, r * 0.65), r * 0.28, PI * 1.1, PI * 1.9, 8, dark, 2.0)
