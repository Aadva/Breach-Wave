extends Node
## Autoload singleton: economy, base health, wave tracking, win/lose.

signal gold_changed(new_gold: int)
signal base_hp_changed(new_hp: int)
signal wave_changed(wave: int)
signal game_over(won: bool)
signal wave_report(income: int, reached: int)  # emitted after a cleared wave pays out

var starting_gold: int = 100
var base_max_hp: int = 20
var total_waves: int = 5
# Wave income = base + performance bonus, so sending tiny "stall" waves doesn't pay.
var wave_base_income: int = 25   # flat gold after each cleared wave
var reach_refund: float = 0.5    # share of a unit's cost refunded when it reaches the base
var damage_bonus: int = 5        # gold per point of base damage dealt

var current_gold: int = 0
var current_base_hp: int = 0
var waves_sent: int = 0
var is_game_over: bool = false

var _wave_earned: int = 0        # performance gold accumulated during the current wave
var _wave_reached: int = 0       # units that reached the base during the current wave


func _ready() -> void:
    reset_game()


func reset_game() -> void:
    current_gold = starting_gold
    current_base_hp = base_max_hp
    waves_sent = 0
    is_game_over = false
    _wave_earned = 0
    _wave_reached = 0
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


## Called by a unit that made it to the base: records its performance bonus, then deals damage.
func unit_reached_base(unit_cost: int, dmg: int) -> void:
    if is_game_over:
        return
    _wave_earned += int(unit_cost * reach_refund) + dmg * damage_bonus
    _wave_reached += 1
    damage_base(dmg)


func wave_sent() -> void:
    waves_sent += 1
    _wave_earned = 0
    _wave_reached = 0
    wave_changed.emit(waves_sent)


## Called when a wave has finished and no units remain on the path.
func wave_cleared() -> void:
    if is_game_over:
        return
    if waves_sent >= total_waves:
        _end(false)  # Out of waves and the base still stands
    else:
        var income := wave_base_income + _wave_earned
        add_gold(income)
        wave_report.emit(income, _wave_reached)
    _wave_earned = 0
    _wave_reached = 0


func _end(won: bool) -> void:
    is_game_over = true
    game_over.emit(won)
