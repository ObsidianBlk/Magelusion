extends Node2D


signal next_level(levelsrc)
signal win_game


func _on_level_exit(next):
	# NOTE: This really is just a passthrough
	emit_signal("next_level", next)


func _on_win_game():
	# Yes... another passthrough
	emit_signal("win_game")
