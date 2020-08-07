extends RigidBody2D

export(float, 0.1, 10000.0) var life = 1.0 setget _setLife
onready var life_max = life

func isAlive():
	return life > 0.0

func _setLife(l):
	if l > 0:
		life = l
		life_max = life

func _process(delta):
	if life > 0.0:
		life -= delta
	
	var collist = get_colliding_bodies()
	if collist.size() > 0:
		for body in collist:
			if body.is_in_group("Fire"):
				print("BURNS!!")

