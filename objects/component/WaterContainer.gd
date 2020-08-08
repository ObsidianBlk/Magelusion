extends Area2D


func _ready():
	connect("body_entered", self, "_on_enter")
	connect("body_exited", self, "_on_exit")


func _on_enter(body):
	if body.is_in_group("Water"):
		body.immortal = true

func _on_exit(body):
	if body.is_in_group("Water"):
		body.immortal = false
