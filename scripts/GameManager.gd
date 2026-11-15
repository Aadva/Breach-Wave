extends Node
## Autoload singleton: economy, base health, wave tracking, win/lose.

signal gold_changed(new_gold: int)
signal base_hp_changed(new_hp: int)
signal wave_changed(wave: int)
signal game_over(won: bool)

var starting_gold: int = 100
var base_max_hp: int = 20
var total_waves: int = 5
var wave_income: int = 50   # gold granted after each cleared wave

var current_gold: int = 0
var current_base_hp: int = 0
var waves_sent: int = 0
var is_game_over: bool = false


func _ready() -> void:
    reset_game()


func reset_game() -> void:
    current_gold = starting_gold
    current_base_hp = base_max_hp
    waves_sent = 0
    is_game_over = false
    gold_changed.emit(current_gold)
    base_hp_changed.emit(current_base_hp)
    wave_changed.emit(waves_sent)


func add_gold(amount: int) -> void:
    current_gold += amount
    gold_changed.emit(current_gold)


func spend_gold(amount: int) -> bool:
    if current_gold >= amount:
        current_gold -= amount
        gold_changed.emit(current_gold)
        return true
    return false


func damage_base(amount: int) -> void:
    if is_game_over:
        return
    current_base_hp = max(0, current_base_hp - amount)
    base_hp_changed.emit(current_base_hp)
    if current_base_hp <= 0:
        _end(true)  # Player wins by reducing the base HP to 0


func wave_sent() -> void:
    waves_sent += 1
    wave_changed.emit(waves_sent)


## Called when a wave has finished and no units remain on the path.
func wave_cleared() -> void:
    if is_game_over:
        return
    if waves_sent >= total_waves:
        _end(false)  # Out of waves and the base still stands
    else:
        add_gold(wave_income)


func _end(won: bool) -> void:
    is_game_over = true
    game_over.emit(won)
