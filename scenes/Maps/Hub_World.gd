extends Node2D

signal next_level(levelsrc)
signal win_game


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.addMusic("Mystery", "res://media/audio/music/Mystery.ogg")
	MusicManager.play("Mystery")



func _on_level_exit(next):
	# NOTE: This really is just a passthrough
	emit_signal("next_level", next)


func _on_win_game():
	# Yes... another passthrough
	emit_signal("win_game")

