extends RigidBody2D

const STEAM_PARTICLE_PATH = "res://objects/steam_particle.tscn"

export(bool) var immortal = false
export(float, 0.1, 10000.0) var life = 1.0 setget _setLife
onready var life_max = life
onready var steam_particle = load(STEAM_PARTICLE_PATH)


func isAlive():
	return life > 0.0

func _setLife(l):
	if l > 0:
		life = l
		life_max = life

func _updateColor(p):
	p = clamp(p, 0.0, 1.0)
	var c = $Sprite.texture.gradient.interpolate(p)
	$Sprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)

func _spawnSteam(count):
	for i in range(count):
		var sp = steam_particle.instance()
		sp.life = rand_range(2.0, 4.0)
		sp.global_position = global_position
		get_tree().root.add_child(sp)

func _process(delta):
	if life > 0.0 and not immortal:
		life -= delta
	_updateColor(linear_velocity.length() / 20.0)
	
	var collist = get_colliding_bodies()
	if collist.size() > 0:
		for body in collist:
			if body.is_in_group("Fire"):
				_spawnSteam(1)
				body.life = 0.0
				life = 0.0

