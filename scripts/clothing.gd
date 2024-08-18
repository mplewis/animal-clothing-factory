class_name Clothing
extends Node2D

@onready var sprite: Sprite2D = $Sprite


func _to_string():
	return "<Clothing %s>" % self.name


## The width of this item of clothing, in pixels, as displayed onscreen
func width_px() -> int:
	(
		Global
		. print_many(
			"Clothing.width_px",
			{
				"width": sprite.texture.get_width(),
				"self.scale": self.scale.x,
				"sprite.scale": sprite.scale.x,
			}
		)
	)
	return int(sprite.texture.get_width() * self.scale.x * sprite.scale.x)
