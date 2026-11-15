class_name Unit
extends PathFollow2D
## A unit walking along the Path2D toward the enemy base.

const TYPES := {
    "skeleton": {"name": "Skeleton", "cost": 10, "hp": 60.0, "speed": 150.0,
        "flying": false, "reward": 2, "base_damage": 1, "radius": 9.0, "icon_radius": 15.0},
    "bat": {"name": "Bat", "cost": 20, "hp": 80.0, "speed": 120.0,
        "flying": true, "reward": 3, "base_damage": 2, "radius": 10.0, "icon_radius": 12.0},
    "slime": {"name": "Slime", "cost": 30, "hp": 350.0, "speed": 80.0,
        "flying": false, "reward": 5, "base_damage": 3, "radius": 14.0, "icon_radius": 13.0},
}

var unit_type: String = "skeleton"
var unit_name: String = "Skeleton"
var max_hp: float = 60.0
var current_hp: float = 60.0
var speed: float = 150.0
var is_flying: bool = false
var gold_reward: int = 2
var base_damage: int = 1
var radius: float = 9.0

var _done: bool = false


func setup(type: String) -> void:
    unit_type = type
    var d: Dictionary = TYPES[type]
    unit_name = d["name"]
    max_hp = d["hp"]
    speed = d["speed"]
    is_flying = d["flying"]
    gold_reward = d["reward"]
    base_damage = d["base_damage"]
    radius = d["radius"]
    current_hp = max_hp


func _ready() -> void:
    loop = false
    rotates = false
    add_to_group("units")
    queue_redraw()


func _process(delta: float) -> void:
    if _done:
        return
    progress += speed * delta
    if progress_ratio >= 1.0:
        reach_base()


func take_damage(amount: float) -> void:
    if _done:
        return
    current_hp -= amount
    queue_redraw()
    if current_hp <= 0.0:
        die()


func die() -> void:
    if _done:
        return
    _done = true
    remove_from_group("units")
    GameManager.add_gold(gold_reward)
    queue_free()


func reach_base() -> void:
    if _done:
        return
    _done = true
    remove_from_group("units")
    GameManager.damage_base(base_damage)
    queue_free()


func _draw() -> void:
    UnitArt.paint(self, unit_type, radius)
    var w := 28.0
    var ratio: float = clamp(current_hp / max_hp, 0.0, 1.0)
    var y := -radius - 12.0
    if unit_type == "bat":
        y -= 6.0
    draw_rect(Rect2(-w / 2.0, y, w, 4.0), Color(0.35, 0.05, 0.05))
    draw_rect(Rect2(-w / 2.0, y, w * ratio, 4.0), Color(0.2, 0.9, 0.2))
