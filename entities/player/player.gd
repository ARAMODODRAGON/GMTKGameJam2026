extends CharacterBody3D

@export var camera: Camera3D

@export_group("Physics")
@export var move_speed: float = 10.0
@export var acceleration: float = 5.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity: float = 1.0
@export var min_camera_pitch: float = -90.0
@export var max_camera_pitch: float = 90.0


## Public Methods

func get_move_vector() -> Vector2:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return Input.get_vector("Left", "Right", "Forward", "Back")
	else:
		return Vector2.ZERO


## Virtual Methods

func _physics_process(delta: float) -> void:
	var move_vector := get_move_vector()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	## Move
	var direction := (transform.basis * Vector3(move_vector.x, 0, move_vector.y)).normalized() * move_speed
	var flat_vel := Vector3(velocity.x, 0.0, velocity.z)

	flat_vel = flat_vel.move_toward(direction, acceleration * delta)
	velocity = Vector3(flat_vel.x, velocity.y, flat_vel.z)


	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	var mouse_input := event as InputEventMouseButton
	if mouse_input:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		return

	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return

		rotation_degrees.y += -mouse_motion.relative.x * mouse_sensitivity
		camera.rotation_degrees.x += -mouse_motion.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, min_camera_pitch, max_camera_pitch)

		return

	var keyboard_input := event as InputEventKey
	if keyboard_input:
		if keyboard_input.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		return
