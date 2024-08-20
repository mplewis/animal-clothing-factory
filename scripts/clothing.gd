class_name Clothing
extends Node2D

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	if material is ShaderMaterial:
		material = material.duplicate()
		var inner_color: Color = Color(randf(),randf(),randf())
		var lineart_color := inner_color.darkened(0.5)
		(material as ShaderMaterial).set_shader_parameter("light_color", inner_color)
		(material as ShaderMaterial).set_shader_parameter("dark_color", lineart_color)


func _to_string():
	return "<Clothing %s>" % self.name


## The width of this item of clothing, in pixels, as displayed onscreen
func width_px() -> int:
	return int(sprite.texture.get_width() * self.scale.x * sprite.scale.x)
