extends RigidBody2D


var life = 2.0
var fade = 0

func _ready():
	life += rand_range(0.25, 2.0)

func _process(delta):
	if life > 0:
		life -= delta
	else:
		fade += delta
		if fade >= 1.0:
			queue_free()
		else:
			modulate = Color(1.0, 1.0, 1.0, 1.0 - fade)
