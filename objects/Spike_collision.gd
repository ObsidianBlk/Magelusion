extends Area2D

export(int, 0, 100) var damage = 5
var player = null


func _ready():
	connect("body_entered", self, "_on_entered")
	connect("body_exited", self, "_on_exited")

func _process(delta):
	if player != null:
		player.takeDamage(damage)

func _on_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("takeDamage"):
			player = body


func _on_exited(body):
	if body == player:
		player = null
