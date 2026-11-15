class_name WaveSpawner
extends Node
## Lets the player queue units, then releases them one by one onto the path.

signal queue_changed
signal wave_started
signal wave_finished_spawning

var path_node: Path2D
var spawn_queue: Array[String] = []
var is_spawning: bool = false
var spawn_delay: float = 0.6


func add_to_queue(unit_type: String) -> bool:
    if is_spawning:
        return false
    var cost: int = Unit.TYPES[unit_type]["cost"]
    if GameManager.spend_gold(cost):
        spawn_queue.append(unit_type)
        queue_changed.emit()
        return true
    return false


func clear_queue() -> void:
    if is_spawning:
        return
    for t in spawn_queue:
        GameManager.add_gold(Unit.TYPES[t]["cost"])  # full refund
    spawn_queue.clear()
    queue_changed.emit()


func start_wave() -> void:
    if is_spawning or spawn_queue.is_empty():
        return
    is_spawning = true
    GameManager.wave_sent()
    wave_started.emit()
    while not spawn_queue.is_empty():
        var unit_type: String = spawn_queue.pop_front()
        var u := Unit.new()
        u.setup(unit_type)
        path_node.add_child(u)
        queue_changed.emit()
        await get_tree().create_timer(spawn_delay).timeout
    is_spawning = false
    wave_finished_spawning.emit()
