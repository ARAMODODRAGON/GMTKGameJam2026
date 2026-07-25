extends CharacterBody3D

@export var camera: Camera3D
@export var camera_ray: RayCast3D

@export_group("Physics")
@export var move_speed: float = 10.0
@export var acceleration: float = 5.0

@export_group("Camera")
@export_range(0.0, 10.0) var mouse_sensitivity: float = 1.0
@export_range(0.0, 10.0) var controller_sensitivity: float = 1.0
@export var min_camera_pitch: float = -90.0
@export var max_camera_pitch: float = 90.0


## Private Variables

var _mouse_captured: bool:
	get:
		return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
var _interactable: BaseInteractable = null


## Public Methods

func get_move_vector() -> Vector2:
	if _mouse_captured:
		return Input.get_vector(&"Left", &"Right", &"Forward", &"Back")
	else:
		return Vector2.ZERO


func get_look_vector() -> Vector2:
	if _mouse_captured:
		# var mouse_look := (Input.get_last_mouse_screen_velocity() / Vector2(get_window().size)) * mouse_sensitivity
		# var joy_look := Input.get_vector(&"JoyLookLeft", &"JoyLookRight", &"JoyLookUp", &"JoyLookDown")
		return Input.get_vector(&"JoyLookLeft", &"JoyLookRight", &"JoyLookUp", &"JoyLookDown") * controller_sensitivity
	else:
		return Vector2.ZERO


## Virtual Methods

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"Interact"):
		_pressed()
	elif Input.is_action_just_released(&"Interact"):
		_released()

	if _interactable:
		if _interactable.global_position.distance_to(global_position) > camera_ray.target_position.length():
			_released()

	## For controller
	var look_vector := get_look_vector()
	rotation_degrees.y += -look_vector.x
	camera.rotation_degrees.x += -look_vector.y
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, min_camera_pitch, max_camera_pitch)

	if camera_ray.get_collider():
		EffectsManager._pointer_set_hitting_interactable.emit(true)
	else:
		EffectsManager._pointer_set_hitting_interactable.emit(false)



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

	var keyboard_input := event as InputEventKey
	if keyboard_input:
		if keyboard_input.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		return

	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return

		rotation_degrees.y += -mouse_motion.relative.x * mouse_sensitivity
		camera.rotation_degrees.x += -mouse_motion.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, min_camera_pitch, max_camera_pitch)

		return


## Private Methods

func _pressed() -> void:

	var object := camera_ray.get_collider()

	if not object:
		return

	var inter := object as BaseInteractable
	if not inter:
		return

	if _interactable:
		_interactable._released()
		_interactable = null

	_interactable = inter
	inter._pressed()


func _released() -> void:
	if _interactable:
		_interactable._released()
		_interactable = null
