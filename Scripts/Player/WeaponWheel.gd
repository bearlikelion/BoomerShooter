class_name WeaponWheel

extends Control

@export var FONT: Font
@export var RADIUS: float = 180.0
@export var DEAD_ZONE: float = 40.0
@export var WHEEL_TIME_SCALE: float = 0.25

var selected_index: int = 0
var _aim: Vector2 = Vector2.ZERO
var _manager: WeaponManager

@onready var player: Player = owner


func _ready() -> void:
	visible = false
	await player.player_ready
	_manager = get_tree().get_first_node_in_group("weapon_manager")


# Hold to open in slow motion, steer with mouse or right stick, release to equip
func _input(event: InputEvent) -> void:
	if _manager == null:
		return

	if event.is_action_pressed("weapon_wheel") and not get_tree().paused:
		_open()
	elif event.is_action_released("weapon_wheel") and visible:
		_close()
	elif visible and event is InputEventMouseMotion:
		_aim += event.relative
		if _aim.length() > RADIUS:
			_aim = _aim.normalized() * RADIUS
		_update_selection()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible or get_tree().paused:
		return

	var stick: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if stick.length() > 0.5:
		_aim = stick * RADIUS
		_update_selection()


func _open() -> void:
	visible = true
	Global.weapon_wheel_open = true
	Engine.time_scale = WHEEL_TIME_SCALE
	selected_index = _manager.current_index
	_aim = Vector2.ZERO
	queue_redraw()


func _close() -> void:
	visible = false
	Global.weapon_wheel_open = false
	Engine.time_scale = 1.0
	_manager.equip(selected_index)


# Pick the wedge the aim vector points at, keeping the current pick inside the dead zone
func _update_selection() -> void:
	if _aim.length() < DEAD_ZONE:
		return

	var segment: float = TAU / _manager.weapons.size()
	var index: int = wrapi(roundi((_aim.angle() + PI / 2.0) / segment), 0, _manager.weapons.size())
	if index != selected_index:
		selected_index = index
		queue_redraw()


func _draw() -> void:
	if _manager == null:
		return

	var center: Vector2 = size / 2.0
	var count: int = _manager.weapons.size()
	var segment: float = TAU / count

	draw_circle(center, RADIUS + 80.0, Color(0.0, 0.0, 0.0, 0.55))

	for i: int in count:
		var angle: float = i * segment - PI / 2.0
		var color: Color = Color(1.0, 1.0, 1.0, 0.9)
		if i == selected_index:
			color = Color(1.0, 0.4, 0.2, 1.0)
			_draw_wedge(center, angle - segment / 2.0, angle + segment / 2.0)

		var weapon_name: String = _manager.weapons[i].weapon_data.weapon_name
		var text_position: Vector2 = center + Vector2.from_angle(angle) * RADIUS + Vector2(-100.0, 10.0)
		draw_string(FONT, text_position, weapon_name, HORIZONTAL_ALIGNMENT_CENTER, 200.0, 32, color)


func _draw_wedge(center: Vector2, from_angle: float, to_angle: float) -> void:
	var points: PackedVector2Array = PackedVector2Array([center])
	var steps: int = 16
	for i: int in steps + 1:
		var angle: float = lerpf(from_angle, to_angle, float(i) / steps)
		points.append(center + Vector2.from_angle(angle) * (RADIUS + 80.0))
	draw_colored_polygon(points, Color(0.9, 0.25, 0.15, 0.35))
