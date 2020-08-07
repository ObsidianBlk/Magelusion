extends RigidBody2D

export(float, 0.1, 10000.0) var life = 1.0 setget _setLife
onready var life_max = life

func isAlive():
	return life > 0.0

func _setLife(l):
	if l > 0:
		life = l
		life_max = life

func _ready():
	_updateColor()

func _process(delta):
	life -= delta
	if life > 0:
		_updateColor()

func _updateColor():
	var lstrength = (life / life_max)
	var c = $Sprite.texture.gradient.interpolate(1.0 - lstrength)
	$Sprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)
	$Light2D.color = c
	$Light2D.energy = lstrength
