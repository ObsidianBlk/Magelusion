extends Node2D

signal win_game

func _ready():
	MusicManager.stop()


func _on_win_game():
	# Yes... another passthrough
	emit_signal("win_game")
