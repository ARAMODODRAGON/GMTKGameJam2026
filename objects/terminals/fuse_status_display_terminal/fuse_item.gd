class_name FuseItem
extends Control

@export var disabled_texture: Texture
@export var enabled_texture: Texture

@export var texture_rect: TextureRect

var state: bool:
	set(value):
		state = value
		if value:
			texture_rect.texture = enabled_texture
		else:
			texture_rect.texture = disabled_texture
