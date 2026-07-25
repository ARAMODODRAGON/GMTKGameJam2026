extends Camera3D

@export var shake_factor: float = 1.0
@export var shake_rate: float = 1.0

@export var h_sway_rate: float = 1.0
@export var v_sway_rate: float = 2.0
@export var rotational_sway_rate: float = 1.0
@export var normal_sway_strength: float = 1.0

@export var low_alignment_threshold: float = 30.0
@export var low_alignment_max_rotational_sway_multiplier: float = 0.8
@export var low_alignment_max_sway_strength_multiplier: float = 2.0

var _shake_amount: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	EffectsManager._camera_shake_screen.connect(_shake_screen)


func _process(delta: float) -> void:
	_time += delta

	var offset := Vector2.ZERO

	if _shake_amount > 0.0:
		_shake_amount -= delta * shake_rate

		offset.x += randf_range(-1.0, 1.0) * _shake_amount * shake_factor
		offset.y += randf_range(-1.0, 1.0) * _shake_amount * shake_factor

	## increase sway at low alignment
	var sway_strength := normal_sway_strength
	var rotation_strength := normal_sway_strength
	if ShipStats.alignment_amount < low_alignment_threshold:
		var factor := 1.0 - (ShipStats.alignment_amount / low_alignment_threshold)
		sway_strength *= lerpf(1.0, low_alignment_max_sway_strength_multiplier, factor)
		rotation_strength *= lerpf(1.0, low_alignment_max_rotational_sway_multiplier, factor)

	## apply sway effect
	offset.x += sin(_time * h_sway_rate) * sway_strength
	offset.y += cos(_time * v_sway_rate) * sway_strength
	rotation_degrees.z = sin(_time * rotational_sway_rate) * 360.0 * rotation_strength

	h_offset = offset.x
	v_offset = offset.y


func _shake_screen(amount: float) -> void:
	_shake_amount = maxf(amount, _shake_amount)


func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		return

	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_L:
		_shake_screen(100.0)
