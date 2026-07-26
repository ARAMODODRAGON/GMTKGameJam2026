extends CharacterBody3D

@export var camera: Camera3D
@export var camera_ray: RayCast3D

@export_group("Physics")
@export var move_speed: float = 10.0
@export var acceleration: float = 5.0

@export_group("Sprint")
@export var sprint_speed: float = 7.0
@export var sprint_time: float = 5.0
@export var sprint_delay: float = 3.0

@export_group("Camera")
@export_range(0.0, 10.0) var mouse_sensitivity: float = 1.0
@export_range(0.0, 10.0) var controller_sensitivity: float = 1.0
@export var min_camera_pitch: float = -90.0
@export var max_camera_pitch: float = 90.0
@onready var normal_camera_fov: float = camera.fov
@export var sprinting_camera_fov: float = 65.0


## Private Variables

var _mouse_captured: bool:
	get:
		return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
var _interactable: BaseInteractable = null
var _is_sprinting: bool = false:
	set(value):
		if _is_sprinting != value:
			_is_sprinting = value
			var tween := camera.create_tween()
			if value:
				tween.tween_property(camera, "fov", sprinting_camera_fov, 0.1)
			else:
				tween.tween_property(camera, "fov", normal_camera_fov, 0.1)

var _sprint_timer: float = 0.0
var _sprint_delay: float = 0.0


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
	var sprint := Input.is_action_pressed(&"Sprint")

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	## start sprinting
	if sprint and not _is_sprinting and _sprint_delay <= 0.0 and velocity.length() > 1.0:
		_is_sprinting = true

	## stop if not moving
	if _is_sprinting and velocity.length() < 1.0:
		_is_sprinting = false

	## stop if sprinting for too long
	if _is_sprinting and _sprint_timer >= sprint_time:
		_is_sprinting = false
		_sprint_delay = sprint_delay
		_sprint_timer = 0.0

	if _sprint_delay > 0.0:
		_sprint_delay -= delta
	if _is_sprinting and _sprint_timer < sprint_time:
		_sprint_timer += delta
	elif not _is_sprinting and _sprint_timer > 0.0:
		_sprint_timer -= delta


	## Move
	var speed := move_speed if not _is_sprinting else sprint_speed
	var direction := (transform.basis * Vector3(move_vector.x, 0, move_vector.y)).normalized() * speed
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


#this is not the win zone
func _on_area_3d_area_entered(area: Area3D) -> void:
	pass

#actual win zone
func _on_area_3d_body_entered(body: Node3D) -> void:
	#pass # Replace with function body.
	print(body.name)
	if body.name == "Player":
		ShipStats.trigger_the_win.call_deferred()
