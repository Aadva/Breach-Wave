class_name Tower
extends Node2D
## Defensive tower. Targets the unit furthest along the path within range.

@export var tower_name: String = "Gunner"
@export var attack_range: float = 170.0
@export var damage: float = 10.0
@export var attack_speed: float = 1.0   # attacks per second
@export var targets_air: bool = false
@export var targets_ground: bool = true
@export var color: Color = Color(0.85, 0.35, 0.35)   # ring colour shows tower type
## Damage multiplier per level-up. 1.05 = +5% per level.
@export var upgrade_multiplier: float = 1.05

var level: int = 1
var cooldown: float = 0.0
var flash_time: float = 0.0
var flash_target: Vector2 = Vector2.ZERO
var hover_area: Control


func _ready() -> void:
	# Invisible Control on top of the tower: gives us the same hover tooltip as the unit buttons.
	hover_area = Control.new()
	hover_area.position = Vector2(-20, -20)
	hover_area.size = Vector2(40, 40)
	hover_area.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(hover_area)
	_update_tooltip()
	queue_redraw()


func _process(delta: float) -> void:
	if flash_time > 0.0:
		flash_time -= delta
		if flash_time <= 0.0:
			queue_redraw()
	cooldown -= delta
	if cooldown > 0.0:
		return

	var target := find_target()
	if target:
		flash_target = target.global_position
		flash_time = 0.08
		cooldown = 1.0 / attack_speed
		queue_redraw()
		target.take_damage(damage)


func find_target() -> Unit:
	var best: Unit = null
	var best_progress: float = -1.0
	for node in get_tree().get_nodes_in_group("units"):
		var u := node as Unit
		if u == null or u.is_queued_for_deletion():
			continue
		if u.is_flying and not targets_air:
			continue
		if not u.is_flying and not targets_ground:
			continue
		if global_position.distance_to(u.global_position) > attack_range:
			continue
		if u.progress > best_progress:
			best_progress = u.progress
			best = u
	return best


func upgrade() -> void:
	level += 1
	damage *= upgrade_multiplier
	_update_tooltip()
	queue_redraw()


func _targets_text() -> String:
	if targets_air and targets_ground:
		return "Ground + Air"
	if targets_air:
		return "Air only"
	return "Ground only"


func _update_tooltip() -> void:
	if hover_area == null:
		return
	hover_area.tooltip_text = "%s | Lv %d | Damage %.1f | Attack speed %.1f/s | DPS %.1f | Range %d | %s" % [
		tower_name, level, damage, attack_speed, damage * attack_speed, attack_range, _targets_text()]


func _draw() -> void:
	var stone := Color(0.3, 0.3, 0.32)
	# Attack range: soft tinted area only (no outline ring)
	draw_circle(Vector2.ZERO, attack_range, Color(color, 0.12))
	# body
	draw_circle(Vector2.ZERO, 19.0, stone)
	draw_arc(Vector2.ZERO, 19.0, 0.0, TAU, 32, Color(0.12, 0.12, 0.14), 3.0)
	draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, color, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(-15, 36), "Lv%d" % level,
		HORIZONTAL_ALIGNMENT_CENTER, 30, 12, Color(1, 1, 1, 0.9))
	if flash_time > 0.0:
		draw_line(Vector2.ZERO, to_local(flash_target), Color(1, 0.95, 0.4), 2.0)
