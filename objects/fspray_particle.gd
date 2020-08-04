extends RigidBody2D

export(float, 0.1, 100.0) var life = 1.0

func isAlive():
	return life > 0.0

func _ready():
	_updateColor()

func _process(delta):
	life -= delta
	if life > 0:
		_updateColor()

func _updateColor():
	var c = $Sprite.texture.gradient.interpolate(life)
	$Sprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)
