class_name UnitArt
extends RefCounted
## Shared drawing code so units on the path and icons in the UI look identical.
## Call from inside a CanvasItem's _draw().

static func paint(c: CanvasItem, type: String, r: float) -> void:
    match type:
        "skeleton":
            _skeleton(c, r)
        "bat":
            _bat(c, r)
        "slime":
            _slime(c, r)


static func _skeleton(c: CanvasItem, r: float) -> void:
    var bone := Color(0.95, 0.95, 0.9)
    var dark := Color(0.08, 0.08, 0.1)
    c.draw_circle(Vector2.ZERO, r, bone)
    c.draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, Color(0, 0, 0, 0.6), 2.0)
    c.draw_circle(Vector2(-r * 0.36, -r * 0.1), r * 0.24, dark)
    c.draw_circle(Vector2(r * 0.36, -r * 0.1), r * 0.24, dark)
    c.draw_circle(Vector2(0, r * 0.2), r * 0.1, dark)
    c.draw_line(Vector2(-r * 0.42, r * 0.5), Vector2(r * 0.42, r * 0.5), dark, 1.5)
    for i in range(-1, 2):
        c.draw_line(Vector2(i * r * 0.22, r * 0.4), Vector2(i * r * 0.22, r * 0.6), dark, 1.2)


static func _bat(c: CanvasItem, r: float) -> void:
    var s := r / 10.0
    var col := Color(0.2, 0.15, 0.28)
    var left := PackedVector2Array([
        Vector2(-4, -3) * s, Vector2(-17, -8) * s, Vector2(-13, -1) * s,
        Vector2(-18, 5) * s, Vector2(-9, 2) * s, Vector2(-4, 4) * s])
    var right := PackedVector2Array([
        Vector2(4, -3) * s, Vector2(17, -8) * s, Vector2(13, -1) * s,
        Vector2(18, 5) * s, Vector2(9, 2) * s, Vector2(4, 4) * s])
    c.draw_colored_polygon(left, col)
    c.draw_colored_polygon(right, col)
    c.draw_circle(Vector2.ZERO, 5.5 * s, col.lightened(0.1))
    c.draw_colored_polygon(PackedVector2Array([
        Vector2(-4.5, -3) * s, Vector2(-3.5, -9) * s, Vector2(-1, -4.5) * s]), col.lightened(0.1))
    c.draw_colored_polygon(PackedVector2Array([
        Vector2(4.5, -3) * s, Vector2(3.5, -9) * s, Vector2(1, -4.5) * s]), col.lightened(0.1))
    c.draw_circle(Vector2(-2.2, -0.8) * s, 1.3 * s, Color(1, 0.2, 0.2))
    c.draw_circle(Vector2(2.2, -0.8) * s, 1.3 * s, Color(1, 0.2, 0.2))


static func _slime(c: CanvasItem, r: float) -> void:
    var body := Color(0.35, 0.55, 0.95)
    var edge := Color(0.18, 0.32, 0.7)
    var pts := PackedVector2Array()
    var rw := r + 3.0
    var rh := r + 1.0
    var dy := r * 0.45
    for i in range(0, 17):
        var a := PI + PI * float(i) / 16.0
        pts.append(Vector2(cos(a) * rw, sin(a) * rh + dy))
    c.draw_colored_polygon(pts, body)
    c.draw_polyline(pts, edge, 2.0)
    c.draw_line(pts[0], pts[pts.size() - 1], edge, 2.0)
    c.draw_circle(Vector2(-r * 0.38, -r * 0.05), r * 0.17, Color(0.05, 0.08, 0.2))
    c.draw_circle(Vector2(r * 0.38, -r * 0.05), r * 0.17, Color(0.05, 0.08, 0.2))
    c.draw_circle(Vector2(-r * 0.45, -r * 0.5), r * 0.2, Color(1, 1, 1, 0.55))
