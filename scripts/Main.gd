extends Node2D
## Builds the level (path, towers, base, UI) and runs the wave loop.

const VIEW_W := 1152
const VIEW_H := 648

var path_points := PackedVector2Array([
    Vector2(-20, 326), Vector2(377, 326), Vector2(377, 502), Vector2(549, 502),
    Vector2(549, 151), Vector2(1010, 151), Vector2(1010, 585),
])

var tower_defs: Array[Dictionary] = [
    {"pos": Vector2(468, 446), "name": "Gunner", "range": 170.0, "damage": 10.0, "speed": 1.0,
        "air": false, "ground": true, "color": Color(0.85, 0.35, 0.35)},
    {"pos": Vector2(595, 296), "name": "Cannon", "range": 185.0, "damage": 30.0, "speed": 0.5,
        "air": true, "ground": true, "color": Color(0.95, 0.6, 0.25)},
    {"pos": Vector2(270, 410), "name": "Flak", "range": 170.0, "damage": 7.0, "speed": 2.0,
        "air": true, "ground": false, "color": Color(0.35, 0.6, 0.95)},
    {"pos": Vector2(930, 215), "name": "Gunner", "range": 170.0, "damage": 10.0, "speed": 1.0,
        "air": false, "ground": true, "color": Color(0.85, 0.35, 0.35)},
    {"pos": Vector2(955, 430), "name": "Flak", "range": 170.0, "damage": 7.0, "speed": 2.0,
        "air": true, "ground": false, "color": Color(0.35, 0.6, 0.95)},
]

var path: Path2D
var towers_root: Node2D
var spawner: WaveSpawner
var wave_active: bool = false

var gold_label: Label
var wave_label: Label
var queue_label: Label
var base_label: Label
var base_bar: ProgressBar
var send_button: Button
var clear_button: Button
var unit_buttons: Dictionary = {}
var report_label: Label
var overlay: ColorRect
var overlay_label: Label


func _ready() -> void:
    _build_map()
    _build_towers()
    _build_ui()

    spawner = WaveSpawner.new()
    spawner.path_node = path
    add_child(spawner)
    spawner.queue_changed.connect(_refresh_ui)
    spawner.wave_started.connect(_on_wave_started)

    GameManager.gold_changed.connect(_refresh_ui)
    GameManager.wave_changed.connect(_refresh_ui)
    GameManager.base_hp_changed.connect(_on_base_hp_changed)
    GameManager.game_over.connect(_on_game_over)
    GameManager.wave_report.connect(_on_wave_report)

    GameManager.reset_game()
    _refresh_ui()


func _process(_delta: float) -> void:
    if GameManager.is_game_over or not wave_active:
        return
    if not spawner.is_spawning and get_tree().get_nodes_in_group("units").is_empty():
        wave_active = false
        for t in towers_root.get_children():
            (t as Tower).upgrade()  # towers get a small boost after every wave
        GameManager.wave_cleared()
        _refresh_ui()


# ---------------------------------------------------------------- map
func _make_path_line(w: float, col: Color) -> Line2D:
    var line := Line2D.new()
    line.points = path_points
    line.width = w
    line.default_color = col
    line.joint_mode = Line2D.LINE_JOINT_ROUND
    line.begin_cap_mode = Line2D.LINE_CAP_ROUND
    line.end_cap_mode = Line2D.LINE_CAP_ROUND
    return line


func _build_map() -> void:
    add_child(GrassBackground.new())

    path = Path2D.new()
    var curve := Curve2D.new()
    for p in path_points:
        curve.add_point(p)
    path.curve = curve
    add_child(path)
    path.add_child(_make_path_line(46.0, Color(0.52, 0.38, 0.24)))
    path.add_child(_make_path_line(36.0, Color(0.85, 0.68, 0.47)))

    # Enemy base at the end of the path (drawn over units so they vanish into it)
    var castle := BaseCastle.new()
    castle.position = Vector2(1010, 606)
    add_child(castle)

    base_label = _make_label("", Vector2(1062, 530), 12, Color.WHITE, Color.BLACK)
    add_child(base_label)
    base_bar = ProgressBar.new()
    base_bar.position = Vector2(1062, 552)
    base_bar.size = Vector2(70, 12)
    base_bar.show_percentage = false
    base_bar.max_value = GameManager.base_max_hp
    base_bar.value = GameManager.base_max_hp
    base_bar.add_theme_stylebox_override("background", _flat_style(Color(0.2, 0.2, 0.2), 2))
    base_bar.add_theme_stylebox_override("fill", _flat_style(Color(0.85, 0.1, 0.1), 2))
    add_child(base_bar)


func _build_towers() -> void:
    towers_root = Node2D.new()
    towers_root.name = "Towers"
    add_child(towers_root)
    for d in tower_defs:
        var t := Tower.new()
        t.position = d["pos"]
        t.tower_name = d["name"]
        t.attack_range = d["range"]
        t.damage = d["damage"]
        t.attack_speed = d["speed"]
        t.targets_air = d["air"]
        t.targets_ground = d["ground"]
        t.color = d["color"]
        towers_root.add_child(t)


# ---------------------------------------------------------------- UI
func _make_label(text: String, pos: Vector2, font_size: int,
        col: Color = Color.WHITE, outline: Color = Color(0, 0, 0, 0)) -> Label:
    var l := Label.new()
    l.text = text
    l.position = pos
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", col)
    if outline.a > 0.0:
        l.add_theme_color_override("font_outline_color", outline)
        l.add_theme_constant_override("outline_size", 4)
    return l


func _flat_style(col: Color, radius: int = 3) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = col
    s.set_corner_radius_all(radius)
    return s


func _tile_style(col: Color) -> StyleBoxFlat:
    var s := _flat_style(col, 3)
    s.set_border_width_all(2)
    s.border_color = Color(0.12, 0.12, 0.12)
    return s


func _build_ui() -> void:
    var ui := CanvasLayer.new()
    add_child(ui)
    var brown := Color(0.72, 0.33, 0.1)

    # Unit bar (behind the currency badge)
    var bar := ColorRect.new()
    bar.color = brown
    bar.position = Vector2(100, 16)
    bar.size = Vector2(250, 76)
    ui.add_child(bar)

    # Round currency badge
    var badge := Panel.new()
    badge.position = Vector2(6, 6)
    badge.size = Vector2(150, 150)
    var sb := _flat_style(Color(0.76, 0.34, 0.1), 75)
    sb.set_border_width_all(10)
    sb.border_color = Color(0.58, 0.25, 0.08)
    badge.add_theme_stylebox_override("panel", sb)
    ui.add_child(badge)

    gold_label = _make_label("0", Vector2(6, 24), 46, Color(0.1, 0.78, 0.72), Color(0.35, 0.15, 0.05))
    gold_label.size = Vector2(150, 60)
    gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ui.add_child(gold_label)

    var soul := SoulIcon.new()
    soul.position = Vector2(53, 86)
    soul.size = Vector2(56, 62)
    ui.add_child(soul)

    # Unit buy buttons (icon tiles with the cost underneath)
    var i := 0
    for type in Unit.TYPES:
        var d: Dictionary = Unit.TYPES[type]
        var x := 170.0 + i * 60.0
        var b := Button.new()
        b.position = Vector2(x, 22)
        b.size = Vector2(48, 48)
        b.add_theme_stylebox_override("normal", _tile_style(Color(0.3, 0.3, 0.32)))
        b.add_theme_stylebox_override("hover", _tile_style(Color(0.4, 0.4, 0.43)))
        b.add_theme_stylebox_override("pressed", _tile_style(Color(0.22, 0.22, 0.24)))
        b.add_theme_stylebox_override("disabled", _tile_style(Color(0.25, 0.25, 0.26)))
        b.tooltip_text = "%s | HP %d | Speed %d | Base dmg %d%s" % [
            d["name"], d["hp"], d["speed"], d["base_damage"],
            " | Flying" if d["flying"] else ""]
        b.pressed.connect(_on_buy.bind(type))
        ui.add_child(b)

        var icon := UnitIcon.new()
        icon.unit_type = type
        icon.art_radius = d["icon_radius"]
        icon.size = Vector2(48, 48)
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        b.add_child(icon)
        unit_buttons[type] = b

        var cost := _make_label(str(d["cost"]), Vector2(x, 71), 14, Color.WHITE, Color(0.3, 0.12, 0.04))
        cost.size = Vector2(48, 18)
        cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        ui.add_child(cost)
        i += 1

    # Instruction text at the top of the screen
    var hint := _make_label("Buy units, send them past the towers, and destroy the enemy base!",
        Vector2(370, 12), 22, Color.WHITE, Color(0.05, 0.1, 0.03))
    hint.size = Vector2(VIEW_W - 390, 32)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ui.add_child(hint)

    # Wave reward summary (shown briefly after each cleared wave)
    report_label = _make_label("", Vector2(370, 48), 26, Color(0.1, 0.78, 0.72), Color(0.05, 0.1, 0.03))
    report_label.size = Vector2(VIEW_W - 390, 36)
    report_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    report_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    report_label.modulate.a = 0.0
    ui.add_child(report_label)

    # Bottom-left control panel
    var bottom := ColorRect.new()
    bottom.color = brown
    bottom.position = Vector2(0, 578)
    bottom.size = Vector2(490, 70)
    ui.add_child(bottom)

    send_button = Button.new()
    send_button.text = "Send Wave"
    send_button.position = Vector2(12, 590)
    send_button.size = Vector2(130, 46)
    send_button.pressed.connect(_on_send_wave)
    ui.add_child(send_button)

    clear_button = Button.new()
    clear_button.text = "Clear"
    clear_button.position = Vector2(152, 590)
    clear_button.size = Vector2(80, 46)
    clear_button.pressed.connect(func(): spawner.clear_queue())
    ui.add_child(clear_button)

    wave_label = _make_label("Wave 0 / 5", Vector2(246, 582), 18, Color.WHITE, Color(0.3, 0.12, 0.04))
    ui.add_child(wave_label)
    queue_label = _make_label("Queue: empty", Vector2(246, 608), 14, Color.WHITE, Color(0.3, 0.12, 0.04))
    queue_label.size = Vector2(236, 36)
    queue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ui.add_child(queue_label)

    # Game-over overlay
    overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.75)
    overlay.size = Vector2(VIEW_W, VIEW_H)
    overlay.visible = false
    ui.add_child(overlay)
    overlay_label = _make_label("", Vector2(0, 220), 40)
    overlay_label.size = Vector2(VIEW_W, 100)
    overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    overlay.add_child(overlay_label)
    var restart := Button.new()
    restart.text = "Play Again"
    restart.position = Vector2(VIEW_W / 2.0 - 80, 340)
    restart.size = Vector2(160, 50)
    restart.pressed.connect(_on_restart)
    overlay.add_child(restart)


func _refresh_ui(_arg = null) -> void:
    if spawner == null or send_button == null:
        return
    gold_label.text = str(GameManager.current_gold)
    wave_label.text = "Wave %d / %d" % [GameManager.waves_sent, GameManager.total_waves]

    var locked := GameManager.is_game_over or spawner.is_spawning
    for type in unit_buttons:
        var cost: int = Unit.TYPES[type]["cost"]
        var b: Button = unit_buttons[type]
        b.disabled = locked or GameManager.current_gold < cost
        (b.get_child(0) as Control).modulate.a = 0.35 if b.disabled else 1.0

    var counts := {}
    for t in spawner.spawn_queue:
        counts[t] = counts.get(t, 0) + 1
    var parts: PackedStringArray = []
    for t in counts:
        parts.append("%dx %s" % [counts[t], Unit.TYPES[t]["name"]])
    queue_label.text = "Queue: " + (", ".join(parts) if parts.size() > 0 else "empty")

    send_button.disabled = locked or wave_active or spawner.spawn_queue.is_empty()
    clear_button.disabled = locked or spawner.spawn_queue.is_empty()


func _on_base_hp_changed(hp: int) -> void:
    if base_bar:
        base_bar.max_value = GameManager.base_max_hp
        base_bar.value = hp
        base_label.text = "Base HP %d / %d" % [hp, GameManager.base_max_hp]


# ---------------------------------------------------------------- actions
func _on_buy(type: String) -> void:
    if GameManager.is_game_over:
        return
    spawner.add_to_queue(type)


func _on_send_wave() -> void:
    if GameManager.is_game_over or wave_active:
        return
    spawner.start_wave()


func _on_wave_started() -> void:
    wave_active = true
    _refresh_ui()


func _on_wave_report(income: int, reached: int) -> void:
    report_label.text = "+%d souls (%d reached base)" % [income, reached]
    report_label.modulate.a = 1.0
    var tw := create_tween()
    tw.tween_interval(2.0)
    tw.tween_property(report_label, "modulate:a", 0.0, 1.0)


func _on_game_over(won: bool) -> void:
    overlay.visible = true
    overlay_label.text = "VICTORY! The enemy base has fallen." if won else "DEFEAT - the base survived all waves."
    _refresh_ui()


func _on_restart() -> void:
    GameManager.reset_game()
    get_tree().reload_current_scene()
