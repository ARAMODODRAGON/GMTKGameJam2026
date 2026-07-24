extends Node3D

@export_enum("Electric", "Nav", "Oxygen", "Shield") var gauge_type: int = 0

@onready var electric_sprite: Sprite3D = $ElectricSprite
@onready var nav_sprite: Sprite3D = $NavSprite
@onready var oxygen_sprite: Sprite3D = $OxygenSprite
@onready var shield_sprite: Sprite3D = $ShieldSprite

@onready var dial: Node3D = $GaugeDial

func _ready() -> void:
	if gauge_type == 0:
		electric_sprite.visible = true;
	elif gauge_type == 1:
		nav_sprite.visible = true;
	elif gauge_type == 2:
		oxygen_sprite.visible = true;
	elif gauge_type == 3:
		shield_sprite.visible = true;

func _process(delta: float) -> void:
	var display_variable: float = 0
	match gauge_type:
		0:
			# electric
			display_variable = ShipStats.energy_amount
		1:
			# nav
			display_variable = ShipStats.alignment_amount
		2:
			# oxygen
			display_variable = ShipStats.oxygen_amount
		3:
			# shield
			display_variable = ShipStats.shield_amount
	
#	90deg is 0%, -90deg 100%
	dial.rotation.y = deg_to_rad(remap(display_variable, 0.0, 100.0, -90.0, 90.0))
