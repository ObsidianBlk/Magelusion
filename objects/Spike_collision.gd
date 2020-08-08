extends Area2D


var player = null


func _ready():
	connect("body_entered", self, "_on_entered")
	connect("body_exited", self, "_on_exited")

func _process(delta):
	if player != null:
		pass

func _on_entered(body):
	if body.is_in_group("Player"):
		pass

func _on_exited(body):
	pass
