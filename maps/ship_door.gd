class_name ShipDoor
extends Node3D


@export var button_1: InteractableButton
@export var button_2: InteractableButton

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var col: CollisionShape3D = $Armature/Skeleton3D/Door/StaticBody3D/CollisionShape3D
@onready var audiostream: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _door_open: bool = false

func _ready() -> void:

	if not button_1:
		print("Button_1 was found to be null")
		return
	button_1.pressed.connect(_toggle_door)

	if not button_2:
		print("Button_2 was found to be null")
		return
	button_2.pressed.connect(_toggle_door)


func _toggle_door() -> void:
	if _door_open:
		anim.play("close_door")
		col.disabled = false
	else:
		anim.play("open_door")
		col.disabled = true
	
	audiostream.play()
	_door_open = !_door_open
