extends Camera3D

@export var shake_factor: float = 1.0
@export var shake_rate: float = 1.0

var _shake_amount: float = 0.0

func _ready() -> void:
	EffectsManager._camera_shake_screen.connect(_shake_screen)


func _process(delta: float) -> void:
	if _shake_amount > 0.0:
		_shake_amount -= delta * shake_rate

		h_offset = randf_range(-1.0, 1.0) * _shake_amount * shake_factor
		v_offset = randf_range(-1.0, 1.0) * _shake_amount * shake_factor


func _shake_screen(amount: float) -> void:
	_shake_amount = maxf(amount, _shake_amount)


func _unhandled_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_L:
		_shake_screen(100.0)
