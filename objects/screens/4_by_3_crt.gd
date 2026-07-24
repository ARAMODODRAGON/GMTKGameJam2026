extends Node3D


@export var label_string: String

@onready var subviewport_label: Label = $SubViewport/Label

func _process(delta: float) -> void:
	subviewport_label.text = label_string
