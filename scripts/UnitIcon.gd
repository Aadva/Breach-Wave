class_name UnitIcon
extends Control
## Draws a unit's art centred in this control (used on the buy buttons).

var unit_type: String = "skeleton"
var art_radius: float = 14.0


func _draw() -> void:
    draw_set_transform(size / 2.0, 0.0, Vector2.ONE)
    UnitArt.paint(self, unit_type, art_radius)
